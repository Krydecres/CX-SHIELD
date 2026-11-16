import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/form_label.dart';
import '../../core/widgets/notice_banner.dart';
import 'google_place_api.dart';
import 'google_place_models.dart';
import 'place_id_utils.dart';

/// D3-05 · Cài đặt phễu: Google Place ID (E4.1), cấu hình theo chi nhánh đang chọn.
class GooglePlacePage extends StatefulWidget {
  const GooglePlacePage({super.key, required this.session, this.isOnboardingStep = false});

  final SessionController session;
  final bool isOnboardingStep;

  @override
  State<GooglePlacePage> createState() => _GooglePlacePageState();
}

class _GooglePlacePageState extends State<GooglePlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _placeId = TextEditingController();
  final _reviewUrl = TextEditingController();
  late final _api = GooglePlaceApi(widget.session.api);

  String? _branchId;
  GooglePlaceConfig? _config;
  bool _loading = true;
  bool _verifying = false;
  bool _saving = false;
  bool _reviewUrlEdited = false;
  String? _loadError;
  String? _placeIdError;
  String? _reviewUrlError;

  String? _placeName;
  String? _placeAddress;
  PlaceConnectionStatus _status = PlaceConnectionStatus.notConnected;
  ({String text, NoticeType type})? _notice;

  bool get _busy => _verifying || _saving;
  bool get _canEdit => widget.session.membership?.canManageFunnel ?? false;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
    _onSessionChanged();
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    _placeId.dispose();
    _reviewUrl.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    final branchId = widget.session.selectedBranch?.id;
    if (branchId != null && branchId != _branchId) {
      _branchId = branchId;
      _load();
    }
  }

  Future<void> _load() async {
    final branchId = _branchId!;
    setState(() {
      _loading = true;
      _loadError = null;
      _notice = null;
    });
    try {
      final config = await _api.load(branchId);
      if (!mounted || branchId != _branchId) return;
      setState(() {
        _config = config;
        _placeId.text = config.placeId ?? '';
        _reviewUrl.text = config.reviewUrl ?? '';
        _reviewUrlEdited = false;
        _placeName = config.placeName;
        _placeAddress = config.placeAddress;
        _status = config.status;
        _placeIdError = null;
        _reviewUrlError = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _loadError = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _placeIdError = null;
      _notice = null;
    });
    if (!_formKey.currentState!.validate()) {
      setState(() => _status = PlaceConnectionStatus.error);
      return;
    }
    setState(() => _verifying = true);
    try {
      final result = await _api.verify(_branchId!, extractPlaceId(_placeId.text));
      if (!mounted) return;
      setState(() {
        _placeId.text = result.placeId;
        _placeName = result.placeName;
        _placeAddress = result.placeAddress;
        _status = result.status;
        if (result.reviewUrl != null && (!_reviewUrlEdited || _reviewUrl.text.trim().isEmpty)) {
          _reviewUrl.text = result.reviewUrl!;
          _reviewUrlEdited = false;
        }
        _notice = (
          text: result.message,
          type: switch (result.status) {
            PlaceConnectionStatus.connected => NoticeType.success,
            PlaceConnectionStatus.error => NoticeType.error,
            _ => NoticeType.info,
          },
        );
      });
    } on ApiException catch (e) {
      _showApiError(e);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _placeIdError = null;
      _reviewUrlError = null;
      _notice = null;
    });
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final placeId = extractPlaceId(_placeId.text);
    final reviewUrl = _reviewUrl.text.trim();
    try {
      final config = await _api.save(
        _branchId!,
        placeId: placeId,
        reviewUrl: _reviewUrlEdited && reviewUrl.isNotEmpty ? reviewUrl : null,
      );
      if (!mounted) return;
      setState(() {
        _config = config;
        _placeId.text = config.placeId ?? placeId;
        _reviewUrl.text = config.reviewUrl ?? '';
        _reviewUrlEdited = false;
        _placeName = config.placeName;
        _placeAddress = config.placeAddress;
        _status = config.status;
        _notice = (
          text: config.status == PlaceConnectionStatus.connected
              ? 'Đã lưu cấu hình. Khách quét mã sẽ được chuyển tới trang đánh giá Google của chi nhánh.'
              : 'Đã lưu cấu hình. Place ID chưa được xác minh với Google.',
          type: NoticeType.success,
        );
      });
    } on ApiException catch (e) {
      _showApiError(e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showApiError(ApiException e) {
    if (!mounted) return;
    setState(() {
      switch (e.code) {
        case 'INVALID_PLACE_ID':
        case 'PLACE_NOT_FOUND':
          _placeIdError = e.message;
          _status = PlaceConnectionStatus.error;
        case 'INVALID_REVIEW_URL':
          _reviewUrlError = e.message;
        default:
          _placeIdError = e.fieldErrors['placeId'];
          _reviewUrlError = e.fieldErrors['reviewUrl'];
          _notice = (text: e.message, type: NoticeType.error);
      }
    });
    _formKey.currentState?.validate();
  }

  Future<void> _openReviewUrl() async {
    final url = _reviewUrl.text.trim().isNotEmpty
        ? _reviewUrl.text.trim()
        : validatePlaceId(_placeId.text) == null
            ? buildReviewUrl(extractPlaceId(_placeId.text))
            : null;
    if (url == null || validateReviewUrl(url) != null) {
      setState(() => _reviewUrlError = 'Chưa có link đánh giá hợp lệ để mở thử.');
      return;
    }
    await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  Future<void> _copyReviewUrl() async {
    if (_reviewUrl.text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _reviewUrl.text.trim()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép link đánh giá.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branch = widget.session.selectedBranch;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(35, 24, 35, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1115),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isOnboardingStep) ...[
                NoticeBanner(
                  title: 'Bước 2/2 · Kết nối Google',
                  message: 'Cơ sở của bạn đã được tạo. Kết nối Google Place ID để khách quét mã được chuyển đúng '
                      'trang đánh giá chính thức, hoặc làm sau trong mục Cài đặt phễu.',
                  action: TextButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Bỏ qua, vào Tổng quan'),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                _FunnelTabBar(currentPath: '/funnel/google-place'),
                const SizedBox(height: 20),
              ],
              Text('Thiết lập Google Business Profile', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Kết nối đúng địa điểm để tạo liên kết đánh giá chính thức.',
                style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 20),
              if (branch == null)
                const NoticeBanner(message: 'Cơ sở chưa có chi nhánh nào để cấu hình.', type: NoticeType.warning)
              else if (_loading)
                const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
              else if (_loadError != null)
                NoticeBanner(
                  message: _loadError!,
                  type: NoticeType.error,
                  action: TextButton(onPressed: _load, child: const Text('Thử lại')),
                )
              else
                _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final config = _config!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_canEdit) ...[
          const NoticeBanner(
            message: 'Bạn chỉ có quyền xem. Chủ cơ sở hoặc Quản lý chi nhánh mới được thay đổi cấu hình.',
            type: NoticeType.warning,
          ),
          const SizedBox(height: 16),
        ],
        if (!config.googleVerificationEnabled) ...[
          const NoticeBanner(
            message: 'Hệ thống chưa bật xác minh tự động với Google: Place ID chỉ được kiểm tra định dạng '
                'và trạng thái sẽ là "Chưa xác minh" sau khi lưu.',
          ),
          const SizedBox(height: 16),
        ],
        const FormLabel('Google Place ID', required: true),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            SizedBox(
              width: 700,
              child: TextFormField(
                controller: _placeId,
                enabled: _canEdit && !_busy,
                decoration: const InputDecoration(hintText: 'Dán Place ID của cơ sở, ví dụ ChIJN1t_tDeuEmsRUsoyG83frY4'),
                validator: (v) => validatePlaceId(v) ?? _placeIdError,
                onChanged: (_) {
                  if (_placeIdError != null || _status == PlaceConnectionStatus.error) {
                    setState(() {
                      _placeIdError = null;
                      _status = _config?.placeId == null ? PlaceConnectionStatus.notConnected : _config!.status;
                    });
                  }
                },
                onFieldSubmitted: (_) => _verify(),
              ),
            ),
            SizedBox(
              width: 170,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.accent,
                  side: BorderSide(color: context.colors.accent),
                ),
                onPressed: _canEdit && !_busy ? _verify : null,
                child: _verifying
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Kiểm tra kết nối'),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => launchUrl(Uri.parse(placeIdFinderUrl), webOnlyWindowName: '_blank'),
            icon: const Icon(Icons.help_outline, size: 16),
            label: const Text('Tìm Place ID của cơ sở ở đâu?'),
          ),
        ),
        const SizedBox(height: 16),
        _PlaceInfoPanel(
          branchName: config.branchName,
          placeName: _placeName,
          placeAddress: _placeAddress,
          status: _status,
          updatedAt: config.updatedAt,
        ),
        if (_notice != null) ...[
          const SizedBox(height: 16),
          NoticeBanner(message: _notice!.text, type: _notice!.type),
        ],
        const SizedBox(height: 22),
        const FormLabel('Link đánh giá Google'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 700,
              child: TextFormField(
                controller: _reviewUrl,
                enabled: _canEdit && !_busy,
                decoration: InputDecoration(
                  hintText: 'Tự lấy sau khi xác minh hoặc nhập thủ công',
                  suffixIcon: IconButton(
                    tooltip: 'Sao chép link',
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    onPressed: _copyReviewUrl,
                  ),
                ),
                validator: (v) => validateReviewUrl(v) ?? _reviewUrlError,
                onChanged: (_) => setState(() {
                  _reviewUrlEdited = true;
                  _reviewUrlError = null;
                }),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _openReviewUrl,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Mở thử'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: 1115,
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 180,
              child: FilledButton(
                onPressed: _canEdit && !_busy ? _save : null,
                child: _saving
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onAccent),
                      )
                    : const Text('Lưu cấu hình'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaceInfoPanel extends StatelessWidget {
  const _PlaceInfoPanel({
    required this.branchName,
    required this.placeName,
    required this.placeAddress,
    required this.status,
    required this.updatedAt,
  });

  final String branchName;
  final String? placeName;
  final String? placeAddress;
  final PlaceConnectionStatus status;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1115,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.secondarySoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.secondaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place_outlined, color: context.colors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Thông tin địa điểm',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.colors.secondary),
              ),
              const Spacer(),
              StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Chi nhánh', value: branchName),
          _InfoRow(label: 'Tên địa điểm', value: placeName),
          _InfoRow(label: 'Địa chỉ', value: placeAddress),
          if (updatedAt != null) _InfoRow(label: 'Cập nhật lần cuối', value: _formatDateTime(updatedAt!)),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)} ${two(t.day)}/${two(t.month)}/${t.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text('$label:', style: TextStyle(color: context.colors.textSecondary))),
          Expanded(
            child: Text(
              value == null || value!.isEmpty ? '—' : value!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final PlaceConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = status.colorsIn(context.colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _FunnelTabBar extends StatelessWidget {
  const _FunnelTabBar({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabItem(
            label: 'Google Place ID (D3-05)',
            icon: Icons.place_outlined,
            selected: currentPath == '/funnel/google-place',
            onTap: () => context.go('/funnel/google-place'),
          ),
          Container(width: 1, height: 32, color: context.colors.border),
          _TabItem(
            label: 'Từ khóa SEO & Phân luồng (D3-07)',
            icon: Icons.tune_rounded,
            selected: currentPath == '/funnel/keywords',
            onTap: () => context.go('/funnel/keywords'),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.accent : context.colors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.colors.accent.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
