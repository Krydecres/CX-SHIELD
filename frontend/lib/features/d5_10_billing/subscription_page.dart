import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/admin_page.dart';
import '../../core/widgets/notice_banner.dart';
import '../d4_01_alert_channels/alert_channels_page.dart' show formatDateTime;
import 'billing_api.dart';
import 'billing_models.dart';

/// D5-12 · Quản lý thuê bao, gia hạn & hóa đơn (E8.3).
/// Theo dõi thời hạn gói, số ngày còn lại, bật/tắt tự động gia hạn,
/// cảnh báo sắp hết hạn, lịch sử giao dịch & tải hóa đơn VAT (PDF/XML).
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key, required this.session, this.openUrl});

  final SessionController session;
  final Future<void> Function(String url)? openUrl;

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late final _api = BillingApi(widget.session.api);
  Subscription? _subscription;
  List<PaymentHistoryItem> _payments = const [];
  List<InvoiceItem> _invoices = const [];
  bool _loading = true;
  bool _updatingAutoRenew = false;
  String? _error;
  String? _loadedBusinessId;

  bool get _isOwner => widget.session.membership?.role == 'OWNER';

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
    final businessId = widget.session.business?.id;
    if (businessId != null && businessId != _loadedBusinessId) {
      _loadedBusinessId = businessId;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final businessId = _loadedBusinessId!;
      final subscription = _isOwner ? await _api.subscription(businessId) : null;
      final payments = _isOwner ? await _api.payments(businessId) : <PaymentHistoryItem>[];
      final invoices = _isOwner ? await _api.invoices(businessId) : <InvoiceItem>[];
      if (!mounted) return;
      setState(() {
        _subscription = subscription;
        _payments = payments;
        _invoices = invoices;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleAutoRenew(bool value) async {
    final businessId = _loadedBusinessId;
    if (businessId == null) return;
    setState(() => _updatingAutoRenew = true);
    try {
      final updated = await _api.updateAutoRenew(businessId, value);
      if (!mounted) return;
      setState(() => _subscription = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? 'Đã bật tự động gia hạn gói dịch vụ.'
              : 'Đã tắt tự động gia hạn gói dịch vụ.'),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingAutoRenew = false);
    }
  }

  Future<void> _openInvoice(String url) async {
    final opener = widget.openUrl ??
        (u) => launchUrl(Uri.parse(u), webOnlyWindowName: '_blank');
    try {
      await opener(url);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở liên kết hóa đơn: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = _subscription;

    return AdminPage(
      title: 'Quản lý thuê bao & hóa đơn',
      subtitle: 'Theo dõi thời hạn gói, số ngày còn lại, tự động gia hạn và tải hóa đơn VAT điện tử (D5-12).',
      actions: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Làm mới'),
            onPressed: _loading ? null : _load,
          ),
          const SizedBox(width: AppSpace.sm),
          ElevatedButton.icon(
            icon: const Icon(Icons.workspace_premium_outlined, size: 18),
            label: const Text('Bảng giá & Đổi gói'),
            onPressed: () => context.go('/billing/plans'),
          ),
        ],
      ),
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          NoticeBanner(
            message: _error!,
            type: NoticeType.error,
            action: TextButton(onPressed: _load, child: const Text('Tải lại')),
          )
        else ...[
          if (!_isOwner) ...[
            const NoticeBanner(
              message: 'Chỉ Chủ cơ sở được quản lý thuê bao, cài đặt gia hạn và xem hóa đơn.',
              type: NoticeType.warning,
            ),
            const SizedBox(height: AppSpace.lg),
          ],

          // Cảnh báo hết hạn hoặc quá hạn
          if (sub != null && sub.isOverdue) ...[
            NoticeBanner(
              type: NoticeType.error,
              title: 'Gói dịch vụ đã quá hạn thanh toán',
              message: 'Gói ${sub.planName ?? ''} đã hết hạn. Vui lòng gia hạn ngay để không làm gián đoạn mã QR khảo sát tại bàn.',
              action: ElevatedButton(
                onPressed: () => context.go('/billing/plans'),
                child: const Text('Gia hạn ngay'),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
          ] else if (sub != null && sub.isExpiringSoon) ...[
            NoticeBanner(
              type: NoticeType.warning,
              title: 'Gói dịch vụ sắp hết hạn',
              message: 'Gói ${sub.planName ?? ''} sẽ hết hạn trong ${sub.daysRemaining} ngày nữa (${_formatDate(sub.endDate)}). Gia hạn ngay để duy trì hoạt động thông suốt.',
              action: ElevatedButton(
                onPressed: () => context.go('/billing/plans'),
                child: const Text('Gia hạn ngay'),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
          ],

          // Thẻ thông tin gói hiện tại & Tự động gia hạn
          ResponsiveGrid(
            maxColumns: 2,
            minItemWidth: 320,
            children: [
              SectionCard(
                title: 'Gói dịch vụ hiện tại',
                subtitle: 'Thông tin chu kỳ sử dụng và thời hạn gói',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          sub?.planName ?? 'Chưa đăng ký gói',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        _buildStatusBadge(context, sub?.status),
                      ],
                    ),
                    const SizedBox(height: AppSpace.md),
                    _buildInfoRow('Chu kỳ thanh toán', sub?.cycle?.label ?? 'Chưa kích hoạt'),
                    _buildInfoRow('Ngày bắt đầu', _formatDate(sub?.startDate)),
                    _buildInfoRow(
                      'Ngày hết hạn',
                      sub?.cycle == BillingCycle.lifetime ? 'Vĩnh viễn' : _formatDate(sub?.endDate),
                    ),
                    _buildInfoRow(
                      'Thời gian còn lại',
                      _formatDaysRemaining(sub),
                      highlight: sub?.isExpiringSoon == true || sub?.isOverdue == true,
                    ),
                  ],
                ),
              ),

              SectionCard(
                title: 'Tự động gia hạn (Auto-renewal)',
                subtitle: 'Duy trì hoạt động liên tục không gián đoạn',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tự động gia hạn khi đến hạn', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text(
                        'Khi bật, hệ thống sẽ nhắc nhở và tự động duy trì gói dịch vụ để bảo đảm mã QR tại quầy luôn hoạt động.',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: sub?.autoRenew ?? false,
                      onChanged: _isOwner && !_updatingAutoRenew
                          ? (value) => _toggleAutoRenew(value)
                          : null,
                    ),
                    if (_updatingAutoRenew)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: LinearProgressIndicator(),
                      ),
                    const SizedBox(height: AppSpace.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpace.md),
                      decoration: BoxDecoration(
                        color: context.colors.sidebarHover.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security_outlined, size: 20, color: context.colors.secondary),
                          const SizedBox(width: AppSpace.sm),
                          const Expanded(
                            child: Text(
                              'Hóa đơn điện tử VAT (PDF & XML) sẽ được xuất tự động sau mỗi lần thanh toán thành công.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpace.xxl),

          // Lịch sử giao dịch & Hóa đơn VAT
          SectionCard(
            title: 'Lịch sử giao dịch & Hóa đơn VAT',
            subtitle: 'Hóa đơn điện tử chuẩn Thông tư 78/2021/TT-BTC, tải về dạng PDF và XML lưu trữ kế toán.',
            child: _payments.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Chưa có giao dịch thanh toán nào được ghi nhận.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(context.colors.sidebarHover.withOpacity(0.08)),
                      columns: const [
                        DataColumn(label: Text('Mã GD', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Gói / Chu kỳ', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Số tiền (gồm VAT)', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Hóa đơn VAT (TT78)', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        for (final payment in _payments)
                          DataRow(
                            cells: [
                              DataCell(SelectableText(
                                payment.transactionCode,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                              )),
                              DataCell(Text(
                                payment.paidAt != null
                                    ? formatDateTime(payment.paidAt!)
                                    : (payment.createdAt != null ? formatDateTime(payment.createdAt!) : '—'),
                              )),
                              DataCell(Text(
                                '${payment.planName ?? 'Gói dịch vụ'} (${payment.billingCycle?.label ?? 'Theo tháng'})',
                              )),
                              DataCell(Text(
                                formatMoney(payment.amount),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              )),
                              DataCell(_buildPaymentStatusBadge(context, payment.status)),
                              DataCell(_buildInvoiceAction(context, payment)),
                            ],
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceAction(BuildContext context, PaymentHistoryItem payment) {
    if (!payment.isSuccess) {
      return const Text('—', style: TextStyle(color: Colors.grey));
    }

    final invoice = _invoices.where((inv) => inv.paymentId == payment.id || inv.transactionCode == payment.transactionCode).firstOrNull;
    final invoiceId = invoice?.id ?? payment.id;
    final businessId = _loadedBusinessId ?? '';
    final pdfUrl = _api.invoicePdfUrl(businessId, invoiceId);
    final xmlUrl = _api.invoiceXmlUrl(businessId, invoiceId);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, size: 15, color: Colors.redAccent),
          label: const Text('PDF', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => _openInvoice(pdfUrl),
        ),
        const SizedBox(width: AppSpace.xs),
        OutlinedButton.icon(
          icon: const Icon(Icons.code, size: 15, color: Colors.blueAccent),
          label: const Text('XML', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => _openInvoice(xmlUrl),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String? status) {
    final (label, color, bg) = switch (status?.toUpperCase()) {
      'ACTIVE' => ('Đang hoạt động', context.colors.success, context.colors.successSoft),
      'TRIAL' => ('Dùng thử', Colors.blue, Colors.blue.withOpacity(0.12)),
      'OVERDUE' => ('Quá hạn', context.colors.error, context.colors.errorSoft),
      'EXPIRED' => ('Hết hạn', Colors.deepOrange, Colors.deepOrange.withOpacity(0.12)),
      'CANCELLED' => ('Đã huỷ', Colors.grey, Colors.grey.withOpacity(0.12)),
      _ => ('Chưa kích hoạt', Colors.grey, Colors.grey.withOpacity(0.12)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(BuildContext context, String status) {
    final (label, color, bg) = switch (status.toUpperCase()) {
      'SUCCESS' => ('Thành công', context.colors.success, context.colors.successSoft),
      'PENDING' => ('Chờ xử lý', context.colors.warning, context.colors.warningSoft),
      _ => ('Thất bại', context.colors.error, context.colors.errorSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? Colors.redAccent : null,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String _formatDaysRemaining(Subscription? sub) {
    if (sub == null) return '—';
    if (sub.cycle == BillingCycle.lifetime) return 'Vĩnh viễn';
    final days = sub.daysRemaining;
    if (days == null) return '—';
    if (days > 0) return 'Còn $days ngày';
    if (days == 0) return 'Hết hạn hôm nay';
    return 'Đã quá hạn ${days.abs()} ngày';
  }
}
