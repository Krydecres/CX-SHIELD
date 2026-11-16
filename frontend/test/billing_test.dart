import 'dart:convert';

import 'package:cx_shield/app/router.dart';
import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d5_10_billing/billing_api.dart';
import 'package:cx_shield/features/d5_10_billing/billing_models.dart';
import 'package:cx_shield/features/d5_10_billing/pricing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const basic = BillingPlan(id: 'p1', name: 'Cơ bản', monthlyPrice: 200000, yearlyPrice: 1920000, lifetimePrice: 990000);
  const advanced = BillingPlan(id: 'p2', name: 'Nâng cao', monthlyPrice: 350000, yearlyPrice: 3360000);
  const plans = [basic, advanced];

  group('đọc dữ liệu API', () {
    test('gói dịch vụ', () {
      final plan = BillingPlan.fromJson({
        'id': 'p1',
        'name': 'Cơ bản',
        'monthlyPrice': 200000,
        'maxBranches': 1,
        'features': ['A', 'B'],
      });

      expect(plan.priceFor(BillingCycle.monthly), 200000);
      expect(plan.priceFor(BillingCycle.yearly), isNull);
      expect(plan.features, ['A', 'B']);
      expect(plan.maxQrCodes, isNull);
    });

    test('mã chu kỳ', () {
      expect(BillingCycle.fromApi('YEARLY'), BillingCycle.yearly);
      expect(BillingCycle.fromApi('LIFETIME'), BillingCycle.lifetime);
      expect(BillingCycle.fromApi(null), isNull);
    });

    test('chưa có thuê bao', () {
      expect(Subscription.fromJson({}).isActive, isFalse);
    });

    test('thuê bao đang hoạt động', () {
      final subscription = Subscription.fromJson({
        'planId': 'p1',
        'planName': 'Cơ bản',
        'billingCycle': 'MONTHLY',
        'status': 'ACTIVE',
        'endDate': '2026-12-06',
      });

      expect(subscription.isActive, isTrue);
      expect(subscription.endDate, DateTime(2026, 12, 6));
      expect(currentPlanText(subscription), 'Bạn đang dùng gói Cơ bản, hết hạn ngày 06/12/2026.');
    });

    test('thuê bao trọn đời không có ngày hết hạn', () {
      expect(currentPlanText(const Subscription(planName: 'Cơ bản', status: 'ACTIVE')), 'Bạn đang dùng gói Cơ bản trọn đời.');
    });

    test('trạng thái thanh toán', () {
      PaymentState state(String status) =>
          PaymentResult.fromJson({'transactionCode': 'CX1', 'status': status}).state;

      expect(state('SUCCESS'), PaymentState.success);
      expect(state('PENDING'), PaymentState.pending);
      expect(state('FAILED'), PaymentState.failed);
    });

    test('hồ sơ hoá đơn rỗng', () {
      expect(BillingProfile.fromJson({}).isEmpty, isTrue);
      expect(BillingProfile.fromJson({'taxCode': '0312345678'}).isEmpty, isFalse);
    });
  });

  group('tiền và VAT', () {
    test('định dạng tiền', () {
      expect(formatMoney(83000), '83.000đ');
      expect(formatMoney(1920000), '1.920.000đ');
      expect(formatMoney(0), '0đ');
    });

    test('VAT 10%', () {
      expect(vatOf(350000), 35000);
    });
  });

  group('nhãn nút trên thẻ gói', () {
    Subscription current(String planId, {BillingCycle cycle = BillingCycle.monthly, String status = 'ACTIVE'}) =>
        Subscription(planId: planId, cycle: cycle, status: status);

    test('chưa có gói', () {
      expect(planActionLabel(basic, BillingCycle.monthly, null, plans), 'Chọn gói');
    });

    test('gói đã hết hạn thì chọn lại', () {
      expect(planActionLabel(basic, BillingCycle.monthly, current('p1', status: 'EXPIRED'), plans), 'Chọn gói');
    });

    test('gói đang dùng thì gia hạn', () {
      expect(planActionLabel(basic, BillingCycle.monthly, current('p1'), plans), 'Gia hạn gói');
    });

    test('gói cao hơn thì nâng cấp', () {
      expect(planActionLabel(advanced, BillingCycle.monthly, current('p1'), plans), 'Nâng cấp gói');
    });

    test('gói thấp hơn thì chọn gói', () {
      expect(planActionLabel(basic, BillingCycle.monthly, current('p2'), plans), 'Chọn gói');
    });

    test('gói trọn đời đang dùng không cần mua lại', () {
      expect(planActionLabel(basic, BillingCycle.monthly, current('p1', cycle: BillingCycle.lifetime), plans), isNull);
    });
  });

  group('kiểm tra nhập liệu', () {
    test('mã số thuế', () {
      expect(validateTaxCode('0312345678'), isNull);
      expect(validateTaxCode('0312345678-001'), isNull);
      expect(validateTaxCode('0312345678001'), isNull);
      expect(validateTaxCode(''), isNotNull);
      expect(validateTaxCode('123'), isNotNull);
    });

    test('email hoá đơn', () {
      expect(validateBillingEmail('ketoan@maison.vn'), isNull);
      expect(validateBillingEmail(''), isNotNull);
      expect(validateBillingEmail('a@b'), isNotNull);
    });
  });

  group('gọi API', () {
    late http.Request captured;

    BillingApi api(Object response) => BillingApi(ApiClient(
          baseUrl: 'http://api',
          accessToken: () => 'token',
          httpClient: MockClient((request) async {
            captured = request;
            return http.Response.bytes(utf8.encode(jsonEncode(response)), 200);
          }),
        ));

    test('danh sách gói', () async {
      final plans = await api([
        {'id': 'p1', 'name': 'Cơ bản'},
      ]).plans();

      expect(captured.url.path, '/api/v1/plans');
      expect(plans.single.name, 'Cơ bản');
    });

    test('tạo lệnh thanh toán không gửi số tiền', () async {
      final result = await api({'transactionCode': 'CX1', 'totalAmount': 385000, 'paymentUrl': 'https://pay'})
          .checkout('biz', planId: 'p1', cycle: BillingCycle.yearly);

      expect(captured.url.path, '/api/v1/businesses/biz/checkouts');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body, {'planId': 'p1', 'billingCycle': 'YEARLY', 'billingProfile': null});
      expect(result.paymentUrl, 'https://pay');
    });

    test('gửi thông tin hoá đơn khi có', () async {
      await api({'transactionCode': 'CX1', 'totalAmount': 1, 'paymentUrl': 'u'}).checkout(
        'biz',
        planId: 'p1',
        cycle: BillingCycle.monthly,
        billingProfile: const BillingProfile(taxCode: '0312345678', companyName: 'A', billingEmail: 'a@b.vn'),
      );

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect((body['billingProfile'] as Map<String, dynamic>)['taxCode'], '0312345678');
    });

    test('đọc kết quả giao dịch', () async {
      final result = await api({'transactionCode': 'CX1', 'status': 'SUCCESS', 'amount': 385000, 'message': 'OK'})
          .payment('biz', 'CX1');

      expect(captured.url.path, '/api/v1/businesses/biz/payments/CX1');
      expect(result.state, PaymentState.success);
    });
  });

  group('giao diện bảng giá', () {
    Widget wrap(Widget child) =>
        MaterialApp(theme: AppTheme.light(), home: Scaffold(body: SingleChildScrollView(child: IntrinsicHeight(child: child))));

    testWidgets('thẻ gói hiện giá theo chu kỳ', (tester) async {
      await tester.pumpWidget(wrap(PlanCard(plan: basic, cycle: BillingCycle.yearly, actionLabel: 'Chọn gói', onChoose: () {})));

      expect(find.text('1.920.000đ'), findsOneWidget);
      expect(find.text('/ năm'), findsOneWidget);
    });

    testWidgets('bấm nút gọi hành động chọn gói', (tester) async {
      var chosen = false;
      await tester.pumpWidget(wrap(PlanCard(
        plan: basic,
        cycle: BillingCycle.monthly,
        actionLabel: 'Nâng cấp gói',
        onChoose: () => chosen = true,
      )));

      await tester.tap(find.text('Nâng cấp gói'));

      expect(chosen, isTrue);
    });

    testWidgets('gói đang dùng không bấm được', (tester) async {
      await tester.pumpWidget(wrap(PlanCard(plan: basic, cycle: BillingCycle.monthly, actionLabel: null, onChoose: () {})));

      expect(find.text('Đang sử dụng'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
    });

    testWidgets('chu kỳ gói không có thì không bấm được', (tester) async {
      await tester.pumpWidget(wrap(PlanCard(plan: advanced, cycle: BillingCycle.lifetime, actionLabel: 'Mua', onChoose: () {})));

      expect(find.text('Liên hệ'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed, isNull);
    });

    testWidgets('gói trọn đời hiện ấn phẩm kèm theo', (tester) async {
      const plan = BillingPlan(id: 'p', name: 'Cơ bản', lifetimePrice: 990000, includedPrintItems: '1 standee mica');
      await tester.pumpWidget(wrap(PlanCard(plan: plan, cycle: BillingCycle.lifetime, actionLabel: 'Mua', onChoose: () {})));

      expect(find.text('1 standee mica'), findsOneWidget);
    });

    testWidgets('bảng so sánh hiện giới hạn', (tester) async {
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: PlanComparisonTable(plans: [
        BillingPlan(id: 'p1', name: 'Cơ bản', maxBranches: 1, maxQrCodes: 10),
        BillingPlan(id: 'p2', name: 'Nâng cao', maxBranches: 1),
      ]))));

      expect(find.text('10'), findsOneWidget);
      expect(find.text('Không giới hạn'), findsOneWidget);
    });
  });

  group('quay về từ cổng thanh toán', () {
    final resultUri = Uri.parse('/billing/plans/result?code=CX1');

    test('giữ trang kết quả khi phiên đang khôi phục', () {
      expect(sessionRedirect(SessionStatus.initializing, false, resultUri), isNull);
      expect(sessionRedirect(SessionStatus.loadingProfile, false, resultUri), isNull);
    });

    test('chưa đăng nhập vẫn phải đăng nhập', () {
      expect(sessionRedirect(SessionStatus.signedOut, false, resultUri), '/login');
    });

    test('trang khác vẫn về màn chờ khi phiên đang khôi phục', () {
      expect(sessionRedirect(SessionStatus.initializing, false, Uri.parse('/billing/plans')), '/');
    });
  });
}
