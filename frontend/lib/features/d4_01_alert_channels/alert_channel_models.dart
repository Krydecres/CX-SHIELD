/// Loại kênh trên D4-01; mã API trùng với enum alert_channel_type trong CSDL.
enum AlertChannelKind {
  telegram('TELEGRAM', 'Telegram Bot'),
  zalo('ZALO', 'Zalo Webhook'),
  email('EMAIL', 'Email');

  const AlertChannelKind(this.apiCode, this.label);

  final String apiCode;
  final String label;

  static AlertChannelKind fromApi(String? value) =>
      AlertChannelKind.values.firstWhere((kind) => kind.apiCode == value, orElse: () => AlertChannelKind.email);
}

class AlertChannel {
  const AlertChannel({
    required this.kind,
    required this.configured,
    required this.enabled,
    this.maskedBotToken,
    this.chatId,
    this.maskedWebhookUrl,
    this.email,
    this.lastTestedAt,
  });

  factory AlertChannel.fromJson(Map<String, dynamic> json) => AlertChannel(
        kind: AlertChannelKind.fromApi(json['type'] as String?),
        configured: json['configured'] as bool? ?? false,
        enabled: json['enabled'] as bool? ?? false,
        maskedBotToken: json['maskedBotToken'] as String?,
        chatId: json['chatId'] as String?,
        maskedWebhookUrl: json['maskedWebhookUrl'] as String?,
        email: json['email'] as String?,
        lastTestedAt: json['lastTestedAt'] == null ? null : DateTime.parse(json['lastTestedAt'] as String).toLocal(),
      );

  final AlertChannelKind kind;
  final bool configured;
  final bool enabled;
  final String? maskedBotToken;
  final String? chatId;
  final String? maskedWebhookUrl;
  final String? email;
  final DateTime? lastTestedAt;
}

class AlertChannelsConfig {
  const AlertChannelsConfig({
    required this.branchId,
    required this.branchName,
    required this.thresholdStar,
    required this.channels,
  });

  factory AlertChannelsConfig.fromJson(Map<String, dynamic> json) => AlertChannelsConfig(
        branchId: json['branchId'] as String,
        branchName: json['branchName'] as String? ?? '',
        thresholdStar: json['thresholdStar'] as int? ?? 4,
        channels: (json['channels'] as List<dynamic>? ?? [])
            .map((channel) => AlertChannel.fromJson(channel as Map<String, dynamic>))
            .toList(),
      );

  final String branchId;
  final String branchName;
  final int thresholdStar;
  final List<AlertChannel> channels;

  AlertChannel channel(AlertChannelKind kind) => channels.firstWhere(
        (channel) => channel.kind == kind,
        orElse: () => AlertChannel(kind: kind, configured: false, enabled: false),
      );
}

class AlertTestResult {
  const AlertTestResult({required this.success, required this.message, this.lastTestedAt});

  factory AlertTestResult.fromJson(Map<String, dynamic> json) => AlertTestResult(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        lastTestedAt: json['lastTestedAt'] == null ? null : DateTime.parse(json['lastTestedAt'] as String).toLocal(),
      );

  final bool success;
  final String message;
  final DateTime? lastTestedAt;
}

/// Kiểm tra nhanh ở giao diện; backend vẫn kiểm tra lại đầy đủ.
String? validateBotToken(String? value, {required bool hasSavedToken}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return hasSavedToken ? null : 'Vui lòng nhập Bot Token.';
  return RegExp(r'^\d{5,}:[A-Za-z0-9_-]{20,}$').hasMatch(text) ? null : 'Bot Token không đúng định dạng.';
}

String? validateChatId(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng nhập Chat ID.';
  return RegExp(r'^(-?\d{1,20}|@[A-Za-z0-9_]{5,32})$').hasMatch(text) ? null : 'Chat ID không đúng định dạng.';
}

String? validateWebhookUrl(String? value, {required bool hasSavedUrl}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return hasSavedUrl ? null : 'Vui lòng nhập Webhook URL.';
  final uri = Uri.tryParse(text);
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty ? null : 'Webhook URL phải là địa chỉ https hợp lệ.';
}

String? validateAlertEmail(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng nhập email nhận cảnh báo.';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text) ? null : 'Email không đúng định dạng.';
}
