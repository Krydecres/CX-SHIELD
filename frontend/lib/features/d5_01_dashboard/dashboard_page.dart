import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/notice_banner.dart';
import '../d3_05_google_place/google_place_api.dart';
import '../d3_05_google_place/google_place_models.dart';
import '../d3_05_google_place/google_place_page.dart';

/// D5-01 · Dashboard tổng quan — màn mặc định sau đăng nhập.
/// Phần thống kê thuộc phân hệ 5 (E3.1); ở đây chỉ có lời chào và danh sách việc cần thiết lập.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.session});

  final SessionController session;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final _googlePlaceApi = GooglePlaceApi(widget.session.api);
  String? _branchId;
  PlaceConnectionStatus? _googleStatus;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_loadGoogleStatus);
    _loadGoogleStatus();
  }

  @override
  void dispose() {
    widget.session.removeListener(_loadGoogleStatus);
    super.dispose();
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
            const NoticeBanner(
              message: 'Biểu đồ lượt quét và tỷ lệ hài lòng sẽ hiển thị tại đây khi phân hệ Báo cáo (E3.1) hoàn thành.',
            ),
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
