import '../../core/api/api_client.dart';
import 'google_place_models.dart';

class GooglePlaceApi {
  GooglePlaceApi(this._api);

  final ApiClient _api;

  Future<GooglePlaceConfig> load(String branchId) async =>
      GooglePlaceConfig.fromJson(await _api.get('/branches/$branchId/google-place') as Map<String, dynamic>);

  Future<PlaceVerification> verify(String branchId, String placeId) async => PlaceVerification.fromJson(
        await _api.post('/branches/$branchId/google-place/verifications', {'placeId': placeId}) as Map<String, dynamic>,
      );

  Future<GooglePlaceConfig> save(String branchId, {required String placeId, String? reviewUrl}) async =>
      GooglePlaceConfig.fromJson(
        await _api.put('/branches/$branchId/google-place', {'placeId': placeId, 'reviewUrl': reviewUrl})
            as Map<String, dynamic>,
      );
}
