import '../../core/api/api_client.dart';
import 'billing_models.dart';

class BillingApi {
  BillingApi(this._api);

  final ApiClient _api;

  Future<List<BillingPlan>> plans() async => (await _api.get('/plans') as List<dynamic>)
      .map((plan) => BillingPlan.fromJson(plan as Map<String, dynamic>))
      .toList();

  Future<Subscription> subscription(String businessId) async =>
      Subscription.fromJson(await _api.get('/businesses/$businessId/subscription') as Map<String, dynamic>);

  Future<BillingProfile> billingProfile(String businessId) async =>
      BillingProfile.fromJson(await _api.get('/businesses/$businessId/billing-profile') as Map<String, dynamic>);

  Future<CheckoutResult> checkout(
    String businessId, {
    required String planId,
    required BillingCycle cycle,
    BillingProfile? billingProfile,
  }) async =>
      CheckoutResult.fromJson(
        await _api.post('/businesses/$businessId/checkouts', {
          'planId': planId,
          'billingCycle': cycle.apiCode,
          'billingProfile': billingProfile?.toJson(),
        }) as Map<String, dynamic>,
      );

  Future<PaymentResult> payment(String businessId, String transactionCode) async => PaymentResult.fromJson(
        await _api.get('/businesses/$businessId/payments/$transactionCode') as Map<String, dynamic>,
      );
}
