import '../../core/api/api_client.dart';
import 'funnel_settings_models.dart';

class FunnelSettingsApi {
  FunnelSettingsApi(this._api);

  final ApiClient _api;

  Future<List<ReviewKeywordModel>> loadKeywords(String businessId, {String? industry}) async {
    final query = industry != null && industry.isNotEmpty ? '?industry=$industry' : '';
    final res = await _api.get('/businesses/$businessId/keywords$query');
    final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
    if (data is List) {
      return data.map((e) => ReviewKeywordModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<ReviewKeywordModel> addKeyword(String businessId, String keyword, {String? industry}) async {
    final res = await _api.post('/businesses/$businessId/keywords', {
      'keyword': keyword,
      if (industry != null) 'industry': industry,
    });
    final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
    return ReviewKeywordModel.fromJson(data as Map<String, dynamic>);
  }

  Future<ReviewKeywordModel> updateKeyword(
    String businessId,
    String keywordId, {
    String? keyword,
    bool? active,
  }) async {
    final res = await _api.put('/businesses/$businessId/keywords/$keywordId', {
      if (keyword != null) 'keyword': keyword,
      if (active != null) 'active': active,
    });
    final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
    return ReviewKeywordModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteKeyword(String businessId, String keywordId) async {
    await _api.delete('/businesses/$businessId/keywords/$keywordId');
  }

  Future<List<ReviewKeywordModel>> applyIndustryTemplate(String businessId, String industry) async {
    final res = await _api.post('/businesses/$businessId/keywords/apply-template?industry=$industry', {});
    final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
    if (data is List) {
      return data.map((e) => ReviewKeywordModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<RoutingRuleModel> loadRoutingRule(String businessId) async {
    final res = await _api.get('/businesses/$businessId/routing-rules');
    final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
    if (data is Map<String, dynamic>) {
      return RoutingRuleModel.fromJson(data);
    }
    return RoutingRuleModel.defaults(businessId);
  }

  Future<RoutingRuleModel> updateRoutingRule(
    String businessId, {
    int? minScore,
    int? maxScore,
    bool? publicReviewEnabled,
  }) async {
    final res = await _api.put('/businesses/$businessId/routing-rules', {
      if (minScore != null) 'satisfiedMinScore': minScore,
      if (maxScore != null) 'satisfiedMaxScore': maxScore,
      if (publicReviewEnabled != null) 'publicReviewEnabled': publicReviewEnabled,
    });
    final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
    return RoutingRuleModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<IndustryTemplateModel>> loadIndustryTemplates() async {
    final res = await _api.get('/funnel-settings/industry-templates');
    final data = res is Map<String, dynamic> ? (res['data'] ?? res) : res;
    if (data is List) {
      return data.map((e) => IndustryTemplateModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

