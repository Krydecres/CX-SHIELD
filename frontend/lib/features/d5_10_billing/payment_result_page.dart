import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/widgets/admin_page.dart';
import '../../core/widgets/notice_banner.dart';
import 'billing_api.dart';
import 'billing_models.dart';

/// Kết quả sau khi VNPAY chuyển trình duyệt về. Trạng thái đọc từ backend, không tin tham số trên URL.
class PaymentResultPage extends StatefulWidget {
  const PaymentResultPage({super.key, required this.session, this.transactionCode});

  final SessionController session;
  final String? transactionCode;

  @override
  State<PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<PaymentResultPage> {
  late final _api = BillingApi(widget.session.api);
  PaymentResult? _result;
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
    super.dispose();
  }

  void _onSessionChanged() {
    final businessId = widget.session.business?.id;
    final code = widget.transactionCode;
    if (code == null) {
      _error = 'Không xác nhận được kết quả giao dịch.';
      return;
    }
    if (businessId != null && businessId != _loadedBusinessId) {
      _loadedBusinessId = businessId;
      _load(businessId, code);
    }
  }

  Future<void> _load(String businessId, String code) async {
    try {
      final result = await _api.payment(businessId, code);
      if (mounted) setState(() => _result = result);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return AdminPage(
      title: 'Kết quả thanh toán',
      children: [
        if (_error != null)
          NoticeBanner(message: _error!, type: NoticeType.error)
        else if (result == null)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
        else
          NoticeBanner(
            title: 'Mã giao dịch ${result.transactionCode} · ${formatMoney(result.amount)}',
            message: result.message,
            type: switch (result.state) {
              PaymentState.success => NoticeType.success,
              PaymentState.pending => NoticeType.info,
              PaymentState.failed => NoticeType.error,
            },
          ),
        const SizedBox(height: AppSpace.lg),
        Wrap(
          spacing: AppSpace.md,
          runSpacing: AppSpace.sm,
          children: [
            FilledButton(onPressed: () => context.go('/dashboard'), child: const Text('Mở trang Tổng quan')),
            OutlinedButton(onPressed: () => context.go('/billing/plans'), child: const Text('Xem bảng giá')),
          ],
        ),
      ],
    );
  }
}
