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
  const Subscription({this.planId, this.planName, this.cycle, this.status, this.endDate});

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        planId: json['planId'] as String?,
        planName: json['planName'] as String?,
        cycle: BillingCycle.fromApi(json['billingCycle'] as String?),
        status: json['status'] as String?,
        endDate: json['endDate'] == null ? null : DateTime.parse(json['endDate'] as String),
      );

  final String? planId;
  final String? planName;
  final BillingCycle? cycle;
  final String? status;
  final DateTime? endDate;

  bool get isActive => status == 'ACTIVE' || status == 'TRIAL';
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
