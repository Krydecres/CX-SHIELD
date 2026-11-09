/// Chu kỳ thanh toán; mã API trùng enum billing_cycle trong CSDL.
enum BillingCycle {
  monthly('MONTHLY', 'Theo tháng', '/ tháng'),
  yearly('YEARLY', 'Theo năm', '/ năm'),
  lifetime('LIFETIME', 'Trọn đời', 'một lần');

  const BillingCycle(this.apiCode, this.label, this.unit);

  final String apiCode;
  final String label;
  final String unit;

  static BillingCycle? fromApi(String? value) {
    for (final cycle in BillingCycle.values) {
      if (cycle.apiCode == value) return cycle;
    }
    return null;
  }
}

class BillingPlan {
  const BillingPlan({
    required this.id,
    required this.name,
    this.monthlyPrice,
    this.yearlyPrice,
    this.lifetimePrice,
    this.maxBranches,
    this.maxQrCodes,
    this.features = const [],
    this.includedPrintItems,
  });

  factory BillingPlan.fromJson(Map<String, dynamic> json) => BillingPlan(
        id: json['id'] as String,
        name: json['name'] as String,
        monthlyPrice: json['monthlyPrice'] as int?,
        yearlyPrice: json['yearlyPrice'] as int?,
        lifetimePrice: json['lifetimePrice'] as int?,
        maxBranches: json['maxBranches'] as int?,
        maxQrCodes: json['maxQrCodes'] as int?,
        features: (json['features'] as List<dynamic>? ?? []).cast<String>(),
        includedPrintItems: json['includedPrintItems'] as String?,
      );

  final String id;
  final String name;
  final int? monthlyPrice;
  final int? yearlyPrice;
  final int? lifetimePrice;
  final int? maxBranches;
  final int? maxQrCodes;
  final List<String> features;
  final String? includedPrintItems;

  int? priceFor(BillingCycle cycle) => switch (cycle) {
        BillingCycle.monthly => monthlyPrice,
        BillingCycle.yearly => yearlyPrice,
        BillingCycle.lifetime => lifetimePrice,
      };
}

class Subscription {
  const Subscription({
    this.planId,
    this.planName,
    this.cycle,
    this.status,
    this.startDate,
    this.endDate,
    this.autoRenew = true,
    this.daysRemaining,
    this.trialEndDate,
    this.graceUntil,
    this.isExpiringSoon = false,
    this.isOverdue = false,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        planId: json['planId'] as String?,
        planName: json['planName'] as String?,
        cycle: BillingCycle.fromApi(json['billingCycle'] as String?),
        status: json['status'] as String?,
        startDate: json['startDate'] == null ? null : DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
        autoRenew: json['autoRenew'] as bool? ?? true,
        daysRemaining: json['daysRemaining'] as int?,
        trialEndDate: json['trialEndDate'] == null ? null : DateTime.parse(json['trialEndDate'] as String),
        graceUntil: json['graceUntil'] == null ? null : DateTime.parse(json['graceUntil'] as String),
        isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
        isOverdue: json['isOverdue'] as bool? ?? false,
      );

  final String? planId;
  final String? planName;
  final BillingCycle? cycle;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final int? daysRemaining;
  final DateTime? trialEndDate;
  final DateTime? graceUntil;
  final bool isExpiringSoon;
  final bool isOverdue;

  bool get isActive => status == 'ACTIVE' || status == 'TRIAL';
  bool get isTrial => status == 'TRIAL';
  bool get isCancelled => status == 'CANCELLED';
  bool get isExpired => status == 'EXPIRED';
}

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.id,
    required this.businessId,
    this.planId,
    this.planName,
    this.billingCycle,
    required this.transactionCode,
    required this.amount,
    required this.status,
    this.method = 'VNPAY',
    this.gatewayResponseCode,
    this.paidAt,
    this.createdAt,
    this.invoiceId,
    this.invoiceNumber,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) => PaymentHistoryItem(
        id: json['id'] as String,
        businessId: json['businessId'] as String,
        planId: json['planId'] as String?,
        planName: json['planName'] as String?,
        billingCycle: BillingCycle.fromApi(json['billingCycle'] as String?),
        transactionCode: json['transactionCode'] as String? ?? '',
        amount: json['amount'] as int? ?? 0,
        status: json['status'] as String? ?? 'PENDING',
        method: json['method'] as String? ?? 'VNPAY',
        gatewayResponseCode: json['gatewayResponseCode'] as String?,
        paidAt: json['paidAt'] == null ? null : DateTime.parse(json['paidAt'] as String),
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        invoiceId: json['invoiceId'] as String?,
        invoiceNumber: json['invoiceNumber'] as String?,
      );

  final String id;
  final String businessId;
  final String? planId;
  final String? planName;
  final BillingCycle? billingCycle;
  final String transactionCode;
  final int amount;
  final String status;
  final String method;
  final String? gatewayResponseCode;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final String? invoiceId;
  final String? invoiceNumber;

  bool get isSuccess => status == 'SUCCESS';
  bool get hasInvoice => isSuccess;
}

class InvoiceItem {
  const InvoiceItem({
    required this.id,
    required this.businessId,
    required this.paymentId,
    required this.transactionCode,
    required this.invoiceNumber,
    this.companyName,
    this.companyAddress,
    this.taxCode,
    this.buyerName,
    this.billingEmail,
    required this.subtotal,
    this.vatRate = 10.0,
    required this.vatAmount,
    required this.totalAmount,
    required this.issuedAt,
    required this.pdfUrl,
    required this.xmlUrl,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json['id'] as String,
        businessId: json['businessId'] as String,
        paymentId: json['paymentId'] as String,
        transactionCode: json['transactionCode'] as String? ?? '',
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        companyName: json['companyName'] as String?,
        companyAddress: json['companyAddress'] as String?,
        taxCode: json['taxCode'] as String?,
        buyerName: json['buyerName'] as String?,
        billingEmail: json['billingEmail'] as String?,
        subtotal: json['subtotal'] as int? ?? 0,
        vatRate: (json['vatRate'] as num?)?.toDouble() ?? 10.0,
        vatAmount: json['vatAmount'] as int? ?? 0,
        totalAmount: json['totalAmount'] as int? ?? 0,
        issuedAt: json['issuedAt'] == null ? DateTime.now() : DateTime.parse(json['issuedAt'] as String),
        pdfUrl: json['pdfUrl'] as String? ?? '',
        xmlUrl: json['xmlUrl'] as String? ?? '',
      );

  final String id;
  final String businessId;
  final String paymentId;
  final String transactionCode;
  final String invoiceNumber;
  final String? companyName;
  final String? companyAddress;
  final String? taxCode;
  final String? buyerName;
  final String? billingEmail;
  final int subtotal;
  final double vatRate;
  final int vatAmount;
  final int totalAmount;
  final DateTime issuedAt;
  final String pdfUrl;
  final String xmlUrl;
}

class BillingProfile {
  const BillingProfile({this.taxCode, this.companyName, this.companyAddress, this.billingEmail, this.buyerName});

  factory BillingProfile.fromJson(Map<String, dynamic> json) => BillingProfile(
        taxCode: json['taxCode'] as String?,
        companyName: json['companyName'] as String?,
        companyAddress: json['companyAddress'] as String?,
        billingEmail: json['billingEmail'] as String?,
        buyerName: json['buyerName'] as String?,
      );

  final String? taxCode;
  final String? companyName;
  final String? companyAddress;
  final String? billingEmail;
  final String? buyerName;

  bool get isEmpty => taxCode == null && companyName == null && billingEmail == null;

  Map<String, dynamic> toJson() => {
        'taxCode': taxCode,
        'companyName': companyName,
        'companyAddress': companyAddress,
        'billingEmail': billingEmail,
        'buyerName': buyerName,
      };
}

class CheckoutResult {
  const CheckoutResult({required this.transactionCode, required this.totalAmount, required this.paymentUrl});

  factory CheckoutResult.fromJson(Map<String, dynamic> json) => CheckoutResult(
        transactionCode: json['transactionCode'] as String,
        totalAmount: json['totalAmount'] as int,
        paymentUrl: json['paymentUrl'] as String,
      );

  final String transactionCode;
  final int totalAmount;
  final String paymentUrl;
}

enum PaymentState { success, pending, failed }

class PaymentResult {
  const PaymentResult({required this.transactionCode, required this.state, required this.amount, required this.message});

  factory PaymentResult.fromJson(Map<String, dynamic> json) => PaymentResult(
        transactionCode: json['transactionCode'] as String,
        state: switch (json['status'] as String?) {
          'SUCCESS' => PaymentState.success,
          'PENDING' => PaymentState.pending,
          _ => PaymentState.failed,
        },
        amount: json['amount'] as int? ?? 0,
        message: json['message'] as String? ?? '',
      );

  final String transactionCode;
  final PaymentState state;
  final int amount;
  final String message;
}

const vatPercent = 10;

/// Số tiền hiển thị theo quy ước: 83.000đ.
String formatMoney(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}đ';

int vatOf(int price) => price * vatPercent ~/ 100;

/// Nhãn nút trên thẻ gói theo gói hiện tại; null nghĩa là gói đang dùng và không cần mua lại.
String? planActionLabel(BillingPlan plan, BillingCycle cycle, Subscription? current, List<BillingPlan> plans) {
  if (current == null || !current.isActive) return 'Chọn gói';
  if (current.planId == plan.id) {
    return current.cycle == BillingCycle.lifetime ? null : 'Gia hạn gói';
  }
  final currentPrice = plans.where((p) => p.id == current.planId).firstOrNull?.monthlyPrice ?? 0;
  return (plan.monthlyPrice ?? 0) > currentPrice ? 'Nâng cấp gói' : 'Chọn gói';
}

String? validateTaxCode(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng nhập mã số thuế.';
  return RegExp(r'^\d{10}(-?\d{3})?$').hasMatch(text) ? null : 'Mã số thuế gồm 10 hoặc 13 chữ số.';
}

String? validateBillingEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng nhập email nhận hoá đơn.';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text) ? null : 'Email không đúng định dạng.';
}
