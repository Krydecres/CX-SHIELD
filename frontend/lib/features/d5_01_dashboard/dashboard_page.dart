import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/admin_page.dart';
import '../../core/widgets/notice_banner.dart';
import '../d3_05_google_place/google_place_api.dart';
import '../d3_05_google_place/google_place_models.dart';
import '../d3_05_google_place/google_place_page.dart';
import 'dashboard_api.dart';
import 'dashboard_models.dart';
import 'dashboard_widgets.dart';

/// D5-01 · Dashboard tổng quan (E3.1) — màn mặc định sau đăng nhập.
/// Thẻ số liệu và biểu đồ theo tuần, lọc theo chi nhánh và khoảng thời gian; kèm việc cần thiết lập.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.session});

  final SessionController session;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final _googlePlaceApi = GooglePlaceApi(widget.session.api);
  late final _dashboardApi = DashboardApi(widget.session.api);
  String? _branchId;
  PlaceConnectionStatus? _googleStatus;

  /// Chi nhánh đang lọc; null là tất cả chi nhánh.
  String? _filterBranchId;
  DashboardRange _range = DashboardRange.weeks8;
  DashboardData? _data;
  bool _loadingData = false;
  String? _dataError;
  String? _loadedBusinessId;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
    _onSessionChanged();
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    _loadGoogleStatus();
    final businessId = widget.session.business?.id;
    if (businessId != null && businessId != _loadedBusinessId) {
      _loadedBusinessId = businessId;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final businessId = widget.session.business?.id;
    if (businessId == null) return;
    final requestId = ++_requestId;
    setState(() {
      _loadingData = true;
      _dataError = null;
    });
    final to = DateTime.now();
    try {
      final data = await _dashboardApi.load(
        businessId,
        branchId: _filterBranchId,
        from: to.subtract(Duration(days: _range.days)),
        to: to,
      );
      if (mounted && requestId == _requestId) setState(() => _data = data);
    } on ApiException catch (e) {
      if (mounted && requestId == _requestId) setState(() => _dataError = e.message);
    } finally {
      if (mounted && requestId == _requestId) setState(() => _loadingData = false);
    }
  }

  Future<void> _loadGoogleStatus() async {
    final branchId = widget.session.selectedBranch?.id;
    if (branchId == null || branchId == _branchId) return;
    _branchId = branchId;
    setState(() => _googleStatus = null);
    try {
      final config = await _googlePlaceApi.load(branchId);
      if (mounted && branchId == _branchId) setState(() => _googleStatus = config.status);
    } on ApiException {
      if (mounted) setState(() => _googleStatus = PlaceConnectionStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return AdminPage(
      title: 'Tổng quan phễu đánh giá',
      subtitle: '${session.business?.brandName ?? ''} · ${_range.label}',
      actions: _buildFilters(),
      children: [
        _buildStats(),
        const SizedBox(height: AppSpace.xl),
        SectionCard(
          title: 'Việc cần thiết lập',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _ChecklistRow(done: true, title: 'Tạo hồ sơ cơ sở và chi nhánh đầu tiên'),
              _ChecklistRow(
                done: _googleStatus == PlaceConnectionStatus.connected || _googleStatus == PlaceConnectionStatus.pending,
                title: 'Kết nối Google Place ID cho chi nhánh ${session.selectedBranch?.name ?? ''}',
                trailing: _googleStatus == null
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusChip(status: _googleStatus!),
                          const SizedBox(width: AppSpace.md),
                          OutlinedButton(
                            onPressed: () => context.go('/funnel/google-place'),
                            child: const Text('Mở cấu hình Google'),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final branchFilter = DropdownButtonFormField<String?>(
      initialValue: _filterBranchId,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Chi nhánh'),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Tất cả chi nhánh')),
        for (final branch in widget.session.branches)
          DropdownMenuItem<String?>(value: branch.id, child: Text(branch.name)),
      ],
      onChanged: (value) {
        setState(() => _filterBranchId = value);
        _loadData();
      },
    );
    final rangeFilter = DropdownButtonFormField<DashboardRange>(
      initialValue: _range,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Khoảng thời gian'),
      items: [
        for (final range in DashboardRange.values) DropdownMenuItem(value: range, child: Text(range.label)),
      ],
      onChanged: (value) {
        if (value == null) return;
        setState(() => _range = value);
        _loadData();
      },
    );
    if (MediaQuery.sizeOf(context).width < 760) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [branchFilter, const SizedBox(height: AppSpace.md), rangeFilter],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 210, child: branchFilter),
        const SizedBox(width: AppSpace.md),
        SizedBox(width: 210, child: rangeFilter),
      ],
    );
  }

  Widget _buildStats() {
    if (_dataError != null) {
      return NoticeBanner(
        message: _dataError!,
        type: NoticeType.error,
        action: TextButton(onPressed: _loadData, child: const Text('Tải lại số liệu')),
      );
    }
    final data = _data;
    if (data == null) {
      return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loadingData) const LinearProgressIndicator(minHeight: 2),
        ResponsiveGrid(
          minItemWidth: 150,
          maxColumns: 5,
          children: [
            MetricCard(label: 'Lượt quét QR', value: formatCount(data.scanCount)),
            MetricCard(
              label: 'Hài lòng 4–5 sao',
              value: formatPercent(data.satisfactionRate),
              note: '${formatCount(data.ratedCount)} lượt đánh giá',
            ),
            MetricCard(label: 'Chuyển sang Google', value: formatCount(data.googleRedirectCount)),
            MetricCard(
              label: 'Đánh giá Google',
              value: data.googleReviewCount == null ? '—' : formatCount(data.googleReviewCount!),
              note: data.googleReviewCount == null ? 'Chưa có dữ liệu' : null,
            ),
            MetricCard(
              label: 'Điểm sao Google',
              value: formatRating(data.googleAvgRating),
              note: data.googleAvgRating == null ? 'Chưa có dữ liệu' : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),
        if (data.isEmpty)
          const NoticeBanner(message: 'Chưa có lượt quét nào trong khoảng thời gian này.')
        else ...[
          ResponsiveGrid(
            minItemWidth: 380,
            maxColumns: 2,
            children: [
              SectionCard(
                title: 'Phễu chuyển đổi',
                subtitle: 'Từ lượt quét QR tới lượt chuyển sang Google',
                child: FunnelChart(steps: data.funnel),
              ),
              SectionCard(title: 'Lượt quét theo tuần', child: WeeklyBarChart(weeks: data.weekly)),
            ],
          ),
          const SizedBox(height: AppSpace.xl),
          SectionCard(title: 'Chi tiết theo tuần', child: WeeklyTable(weeks: data.weekly)),
        ],
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.done, required this.title, this.trailing});

  final bool done;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < compactWidth;
          return Row(
            crossAxisAlignment: stacked ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: done ? context.colors.success : context.colors.textMuted,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title),
                    if (stacked && trailing != null) ...[
                      const SizedBox(height: AppSpace.sm),
                      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: trailing),
                    ],
                  ],
                ),
              ),
              if (!stacked) ?trailing,
            ],
          );
        },
      ),
    );
  }
}
