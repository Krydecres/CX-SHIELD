import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
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
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(35),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1115),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào, ${session.me?.displayName ?? ''}', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '${session.business?.brandName ?? ''} · Chi nhánh ${session.selectedBranch?.name ?? '—'}',
              style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thiết lập ban đầu', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 14),
                    const _ChecklistRow(done: true, title: 'Tạo hồ sơ cơ sở và chi nhánh đầu tiên'),
                    _ChecklistRow(
                      done: _googleStatus == PlaceConnectionStatus.connected ||
                          _googleStatus == PlaceConnectionStatus.pending,
                      title: 'Kết nối Google Place ID cho chi nhánh',
                      trailing: _googleStatus == null
                          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StatusChip(status: _googleStatus!),
                                const SizedBox(width: 12),
                                FilledButton(
                                  onPressed: () => context.go('/funnel/google-place'),
                                  child: Text(
                                    _googleStatus == PlaceConnectionStatus.connected ? 'Xem cấu hình' : 'Thiết lập',
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<String?>(
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
          ),
        ),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<DashboardRange>(
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
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    if (_dataError != null) {
      return NoticeBanner(
        message: _dataError!,
        type: NoticeType.error,
        action: TextButton(onPressed: _loadData, child: const Text('Thử lại')),
      );
    }
    final data = _data;
    if (data == null) {
      return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loadingData) const LinearProgressIndicator(minHeight: 2),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final card in [
              MetricCard(label: 'Lượt quét QR', value: formatCount(data.scanCount)),
              MetricCard(
                label: 'Tỷ lệ hài lòng (4–5 sao)',
                value: formatPercent(data.satisfactionRate),
                note: '${formatCount(data.ratedCount)} lượt đánh giá',
              ),
              MetricCard(label: 'Chuyển sang Google', value: formatCount(data.googleRedirectCount)),
              MetricCard(
                label: 'Đánh giá trên Google',
                value: data.googleReviewCount == null ? '—' : formatCount(data.googleReviewCount!),
                note: data.googleReviewCount == null ? 'Chưa có dữ liệu' : null,
              ),
              MetricCard(
                label: 'Điểm sao Google',
                value: formatRating(data.googleAvgRating),
                note: data.googleAvgRating == null ? 'Chưa có dữ liệu' : null,
              ),
            ])
              SizedBox(width: 205, child: card),
          ],
        ),
        const SizedBox(height: 16),
        if (data.isEmpty)
          const NoticeBanner(message: 'Chưa có lượt quét nào trong khoảng thời gian này.')
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lượt quét theo tuần', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  WeeklyBarChart(weeks: data.weekly),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chi tiết theo tuần', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  WeeklyTable(weeks: data.weekly),
                ],
              ),
            ),
          ),
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
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? context.colors.success : context.colors.textMuted,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          ?trailing,
        ],
      ),
    );
  }
}
