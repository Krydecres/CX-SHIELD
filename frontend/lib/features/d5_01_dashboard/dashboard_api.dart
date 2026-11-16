import '../../core/api/api_client.dart';
import 'dashboard_models.dart';

class DashboardApi {
  DashboardApi(this._api);

  final ApiClient _api;

  Future<DashboardData> load(String businessId, {String? branchId, required DateTime from, required DateTime to}) async {
    final query = {
      'branchId': ?branchId,
      'from': apiDate(from),
      'to': apiDate(to),
    };
    final path = Uri(path: '/businesses/$businessId/dashboard', queryParameters: query).toString();
    return DashboardData.fromJson(await _api.get(path) as Map<String, dynamic>);
  }
}
