import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/admin_page.dart';
import '../../core/widgets/form_label.dart';
import '../../core/widgets/notice_banner.dart';
import 'alert_channel_api.dart';
import 'alert_channel_models.dart';

/// D4-01 · Cài kênh cảnh báo Telegram / Zalo / Email (E2.1), cấu hình theo chi nhánh đang chọn.
class AlertChannelsPage extends StatefulWidget {
  const AlertChannelsPage({super.key, required this.session});

  final SessionController session;

  @override
  State<AlertChannelsPage> createState() => _AlertChannelsPageState();
}

class _AlertChannelsPageState extends State<AlertChannelsPage> {
  late final _api = AlertChannelApi(widget.session.api);
  String? _branchId;
  AlertChannelsConfig? _config;
  bool _loading = true;
  String? _loadError;

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
    });
    try {
      final config = await _api.load(branchId);
      if (mounted && branchId == _branchId) setState(() => _config = config);
    } on ApiException catch (e) {
      if (mounted) setState(() => _loadError = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.session.selectedBranch;
    final config = _config;
    return AdminPage(
      title: 'Kênh cảnh báo chi nhánh',
      subtitle: config == null
          ? 'Nơi nhận tin khi khách gửi góp ý chưa hài lòng.'
          : 'Góp ý dưới ${config.thresholdStar} sao tại ${config.branchName} gửi tin tới các kênh đang bật.',
      children: [
        if (branch == null)
          const NoticeBanner(message: 'Cơ sở chưa có chi nhánh nào để cấu hình.', type: NoticeType.warning)
        else if (_loading)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
        else if (_loadError != null)
          NoticeBanner(
            message: _loadError!,
            type: NoticeType.error,
            action: TextButton(onPressed: _load, child: const Text('Tải lại kênh')),
          )
        else if (config != null) ...[
          if (!_canEdit) ...[
            const NoticeBanner(
              message: 'Bạn chỉ có quyền xem. Chủ cơ sở hoặc Quản lý chi nhánh mới được thay đổi cấu hình.',
              type: NoticeType.warning,
            ),
            const SizedBox(height: AppSpace.lg),
          ],
          ResponsiveGrid(
            minItemWidth: 300,
            children: [
              for (final kind in AlertChannelKind.values)
                AlertChannelCard(
                  key: ValueKey('${config.branchId}-${kind.apiCode}'),
                  channel: config.channel(kind),
                  canEdit: _canEdit,
                  onSave: ({required enabled, botToken, chatId, webhookUrl, email}) => _api.save(
                    config.branchId,
                    kind,
                    enabled: enabled,
                    botToken: botToken,
                    chatId: chatId,
                    webhookUrl: webhookUrl,
                    email: email,
                  ),
                  onTest: () => _api.sendTest(config.branchId, kind),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

typedef SaveAlertChannel = Future<AlertChannel> Function({
  required bool enabled,
  String? botToken,
  String? chatId,
  String? webhookUrl,
  String? email,
});

/// Thẻ cấu hình một kênh: nhập thông tin, bật / tắt, lưu và gửi thử.
class AlertChannelCard extends StatefulWidget {
  const AlertChannelCard({
    super.key,
    required this.channel,
    required this.canEdit,
    required this.onSave,
    required this.onTest,
  });

  final AlertChannel channel;
  final bool canEdit;
  final SaveAlertChannel onSave;
  final Future<AlertTestResult> Function() onTest;

  @override
  State<AlertChannelCard> createState() => _AlertChannelCardState();
}

class _AlertChannelCardState extends State<AlertChannelCard> {
  final _formKey = GlobalKey<FormState>();
  late final _botToken = TextEditingController();
  late final _chatId = TextEditingController(text: widget.channel.chatId);
  late final _webhookUrl = TextEditingController();
  late final _email = TextEditingController(text: widget.channel.email);
  late AlertChannel _channel = widget.channel;
  late bool _enabled = widget.channel.configured ? widget.channel.enabled : true;
  bool _saving = false;
  bool _testing = false;
  ({String text, NoticeType type})? _notice;

  bool get _busy => _saving || _testing;

  @override
  void dispose() {
    _botToken.dispose();
    _chatId.dispose();
    _webhookUrl.dispose();
    _email.dispose();
    super.dispose();
  }

  static String? _nonBlank(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    setState(() => _notice = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.onSave(
        enabled: _enabled,
        botToken: _nonBlank(_botToken),
        chatId: _nonBlank(_chatId),
        webhookUrl: _nonBlank(_webhookUrl),
        email: _nonBlank(_email),
      );
      if (!mounted) return;
      setState(() {
        _channel = saved;
        _botToken.clear();
        _webhookUrl.clear();
        _notice = (text: 'Đã lưu cấu hình kênh.', type: NoticeType.success);
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _notice = (text: e.message, type: NoticeType.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _notice = null;
    });
    try {
      final result = await widget.onTest();
      if (!mounted) return;
      setState(() {
        _notice = (text: result.message, type: result.success ? NoticeType.success : NoticeType.error);
        _channel = AlertChannel(
          kind: _channel.kind,
          configured: _channel.configured,
          enabled: _channel.enabled,
          maskedBotToken: _channel.maskedBotToken,
          chatId: _channel.chatId,
          maskedWebhookUrl: _channel.maskedWebhookUrl,
          email: _channel.email,
          lastTestedAt: result.lastTestedAt ?? _channel.lastTestedAt,
        );
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _notice = (text: e.message, type: NoticeType.error));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editable = widget.canEdit && !_busy;
    final tested = _channel.lastTestedAt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_channel.kind.label, style: theme.textTheme.titleMedium),
                        Text(channelStateLabel(_channel), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: editable ? (value) => setState(() => _enabled = value) : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.lg),
              ..._fields(editable),
              const Spacer(),
              if (_notice != null) ...[
                const SizedBox(height: AppSpace.md),
                NoticeBanner(message: _notice!.text, type: _notice!.type),
              ],
              const SizedBox(height: AppSpace.lg),
              FilledButton(
                onPressed: editable ? _save : null,
                child: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Lưu kênh'),
              ),
              const SizedBox(height: AppSpace.sm),
              OutlinedButton(
                onPressed: editable && _channel.configured ? _test : null,
                child: _testing
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Gửi tin thử'),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                tested == null ? 'Chưa gửi tin thử' : 'Gửi thử gần nhất: ${formatDateTime(tested)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fields(bool editable) => switch (_channel.kind) {
        AlertChannelKind.telegram => [
            const FormLabel('Bot Token', required: true),
            TextFormField(
              controller: _botToken,
              enabled: editable,
              obscureText: true,
              decoration: InputDecoration(hintText: _channel.maskedBotToken ?? '123456789:AAE...'),
              validator: (value) => validateBotToken(value, hasSavedToken: _channel.maskedBotToken != null),
            ),
            if (_channel.maskedBotToken != null) const _KeepSavedHint(),
            const SizedBox(height: AppSpace.md),
            const FormLabel('Chat ID', required: true),
            TextFormField(
              controller: _chatId,
              enabled: editable,
              decoration: const InputDecoration(hintText: '-1001234567890'),
              validator: validateChatId,
            ),
          ],
        AlertChannelKind.zalo => [
            const FormLabel('Webhook URL', required: true),
            TextFormField(
              controller: _webhookUrl,
              enabled: editable,
              decoration: InputDecoration(hintText: _channel.maskedWebhookUrl ?? 'https://...'),
              validator: (value) => validateWebhookUrl(value, hasSavedUrl: _channel.maskedWebhookUrl != null),
            ),
            if (_channel.maskedWebhookUrl != null) const _KeepSavedHint(),
          ],
        AlertChannelKind.email => [
            const FormLabel('Email nhận cảnh báo', required: true),
            TextFormField(
              controller: _email,
              enabled: editable,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'quanly@coso.vn'),
              validator: validateAlertEmail,
            ),
          ],
      };
}

/// Trạng thái kênh hiển thị dưới tên kênh.
String channelStateLabel(AlertChannel channel) {
  if (!channel.configured) return 'Chưa cấu hình';
  return channel.enabled ? 'Đang bật' : 'Đang tắt';
}

class _KeepSavedHint extends StatelessWidget {
  const _KeepSavedHint();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpace.xs),
        child: Text(
          'Đã lưu và được che. Để trống nếu không đổi.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
        ),
      );
}

/// Định dạng dd/MM/yyyy HH:mm theo quy ước giao diện.
String formatDateTime(DateTime time) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(time.day)}/${two(time.month)}/${time.year} ${two(time.hour)}:${two(time.minute)}';
}
