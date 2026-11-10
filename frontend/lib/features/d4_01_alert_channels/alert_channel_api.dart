import '../../core/api/api_client.dart';
import 'alert_channel_models.dart';

class AlertChannelApi {
  AlertChannelApi(this._api);

  final ApiClient _api;

  Future<AlertChannelsConfig> load(String branchId) async =>
      AlertChannelsConfig.fromJson(await _api.get('/branches/$branchId/alert-channels') as Map<String, dynamic>);

  Future<AlertChannel> save(
    String branchId,
    AlertChannelKind kind, {
    required bool enabled,
    String? botToken,
    String? chatId,
    String? webhookUrl,
    String? email,
  }) async =>
      AlertChannel.fromJson(
        await _api.put('/branches/$branchId/alert-channels/${kind.apiCode}', {
          'enabled': enabled,
          'botToken': botToken,
          'chatId': chatId,
          'webhookUrl': webhookUrl,
          'email': email,
        }) as Map<String, dynamic>,
      );

  Future<AlertTestResult> sendTest(String branchId, AlertChannelKind kind) async => AlertTestResult.fromJson(
        await _api.post('/branches/$branchId/alert-channels/${kind.apiCode}/tests', {}) as Map<String, dynamic>,
      );
}
