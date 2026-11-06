import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/form_label.dart';
import '../../core/widgets/notice_banner.dart';
import 'billing_api.dart';
import 'billing_models.dart';

/// D5-11 · Thanh toán và thông tin xuất hoá đơn (E8.2). Chuyển sang VNPAY để khách chọn QR, thẻ ATM hoặc thẻ quốc tế.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.session, required this.planId, required this.cycle, this.openPaymentUrl});

  final SessionController session;
  final String? planId;
  final BillingCycle? cycle;

  /// Thay thế việc mở trình duyệt khi test.
  final Future<void> Function(String url)? openPaymentUrl;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _taxCode = TextEditingController();
  final _companyName = TextEditingController();
  final _companyAddress = TextEditingController();
  final _billingEmail = TextEditingController();
  final _buyerName = TextEditingController();
  late final _api = BillingApi(widget.session.api);

  BillingPlan? _plan;
  bool _needInvoice = false;
  bool _loading = true;
  bool _paying = false;
  String? _error;
  String? _loadedBusinessId;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
    _onSessionChanged();
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    _taxCode.dispose();
    _companyName.dispose();
    _companyAddress.dispose();
    _billingEmail.dispose();
    _buyerName.dispose();
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
      final plans = await _api.plans();
      final profile = await _api.billingProfile(_loadedBusinessId!);
      if (!mounted) return;
      setState(() {
        _plan = plans.where((plan) => plan.id == widget.planId).firstOrNull;
        _taxCode.text = profile.taxCode ?? '';
        _companyName.text = profile.companyName ?? '';
        _companyAddress.text = profile.companyAddress ?? '';
        _billingEmail.text = profile.billingEmail ?? '';
        _buyerName.text = profile.buyerName ?? '';
        _needInvoice = !profile.isEmpty;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _paying = true;
      _error = null;
    });
    try {
      final result = await _api.checkout(
        _loadedBusinessId!,
        planId: _plan!.id,
        cycle: widget.cycle!,
        billingProfile: _needInvoice
            ? BillingProfile(
                taxCode: _taxCode.text.trim(),
                companyName: _companyName.text.trim(),
                companyAddress: _companyAddress.text.trim(),
                billingEmail: _billingEmail.text.trim(),
                buyerName: _buyerName.text.trim(),
              )
            : null,
      );
      final open = widget.openPaymentUrl ?? (url) => launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
      await open(result.paymentUrl);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(35, 24, 35, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1115),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => context.go('/billing/plans'),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Quay lại bảng giá'),
            ),
            Text('Thanh toán', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (_plan == null || widget.cycle == null || _plan!.priceFor(widget.cycle!) == null)
              NoticeBanner(message: _error ?? 'Không tìm thấy gói đã chọn.', type: NoticeType.error)
            else
              _buildContent(_plan!, widget.cycle!),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BillingPlan plan, BillingCycle cycle) {
    return Form(
      key: _formKey,
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          SizedBox(width: 640, child: _buildInvoiceCard()),
          SizedBox(width: 400, child: _buildSummary(plan, cycle)),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phương thức thanh toán', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const NoticeBanner(
              message: 'Bạn sẽ được chuyển sang cổng VNPAY để chọn mã QR, thẻ ATM nội địa hoặc thẻ quốc tế.',
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tôi cần xuất hoá đơn VAT'),
              value: _needInvoice,
              onChanged: _paying ? null : (value) => setState(() => _needInvoice = value),
            ),
            if (_needInvoice) ...[
              const SizedBox(height: 8),
              const FormLabel('Mã số thuế', required: true),
              TextFormField(controller: _taxCode, enabled: !_paying, validator: validateTaxCode),
              const SizedBox(height: 12),
              const FormLabel('Tên công ty', required: true),
              TextFormField(
                controller: _companyName,
                enabled: !_paying,
                validator: (value) => (value?.trim() ?? '').isEmpty ? 'Vui lòng nhập tên công ty.' : null,
              ),
              const SizedBox(height: 12),
              const FormLabel('Địa chỉ công ty'),
              TextFormField(controller: _companyAddress, enabled: !_paying),
              const SizedBox(height: 12),
              const FormLabel('Email nhận hoá đơn điện tử', required: true),
              TextFormField(controller: _billingEmail, enabled: !_paying, validator: validateBillingEmail),
              const SizedBox(height: 12),
              const FormLabel('Người mua hàng'),
              TextFormField(controller: _buyerName, enabled: !_paying),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BillingPlan plan, BillingCycle cycle) {
    final price = plan.priceFor(cycle)!;
    final vat = vatOf(price);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tóm tắt đơn hàng', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _SummaryRow('Gói', plan.name),
            _SummaryRow('Chu kỳ', cycle.label),
            _SummaryRow('Giá gói', formatMoney(price)),
            _SummaryRow('Thuế GTGT ($vatPercent%)', formatMoney(vat)),
            Divider(color: context.colors.border),
            _SummaryRow('Tổng thanh toán', formatMoney(price + vat), bold: true),
            if (_error != null) ...[
              const SizedBox(height: 12),
              NoticeBanner(message: _error!, type: NoticeType.error),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _paying ? null : _pay,
                child: _paying
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Thanh toán ${formatMoney(price + vat)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
