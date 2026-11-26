import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cx_shield/features/d5_10_billing/billing_models.dart';
import 'package:cx_shield/features/d5_10_billing/pricing_page.dart';

const basicPlan = BillingPlan(
  id: 'plan-basic',
  name: 'Cơ bản',
  monthlyPrice: 200000,
  yearlyPrice: 1920000,
  lifetimePrice: 990000,
  maxBranches: 1,
  maxQrCodes: 10,
);

const advancedPlan = BillingPlan(
  id: 'plan-advanced',
  name: 'Nâng cao',
  monthlyPrice: 350000,
  yearlyPrice: 3360000,
  lifetimePrice: 1490000,
  maxBranches: 3,
  maxQrCodes: 50,
);

const chainPlan = BillingPlan(
  id: 'plan-chain',
  name: 'Chuỗi',
  monthlyPrice: 500000,
  yearlyPrice: 4800000,
);

const testPlans = [basicPlan, advancedPlan, chainPlan];

Widget wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: SizedBox(width: 500, height: 650, child: child)),
    ),
  );
}

void main() {
  group('SCRUM-245 - Pricing data tests', () {
    test('AT-245-01: Có đủ ba gói dịch vụ', () {
      expect(testPlans.length, 3);
      expect(testPlans.map((p) => p.name).toList(), [
        'Cơ bản',
        'Nâng cao',
        'Chuỗi',
      ]);
    });

    test('AT-245-02: Giá tháng chính xác', () {
      expect(basicPlan.priceFor(BillingCycle.monthly), 200000);
      expect(advancedPlan.priceFor(BillingCycle.monthly), 350000);
      expect(chainPlan.priceFor(BillingCycle.monthly), 500000);
    });

    test('AT-245-03: Giá năm chính xác', () {
      expect(basicPlan.priceFor(BillingCycle.yearly), 1920000);
      expect(advancedPlan.priceFor(BillingCycle.yearly), 3360000);
      expect(chainPlan.priceFor(BillingCycle.yearly), 4800000);
    });

    test('AT-245-04: Giá trọn đời chính xác', () {
      expect(basicPlan.priceFor(BillingCycle.lifetime), 990000);
      expect(advancedPlan.priceFor(BillingCycle.lifetime), 1490000);
    });

    test('AT-245-05: Chu kỳ không có giá trả về null', () {
      expect(chainPlan.priceFor(BillingCycle.lifetime), isNull);
    });

    test('AT-245-06: Định dạng giá chính xác', () {
      expect(formatMoney(200000), '200.000đ');
      expect(formatMoney(1920000), '1.920.000đ');
      expect(formatMoney(1490000), '1.490.000đ');
    });

    test('AT-245-07: VAT bằng 10%', () {
      expect(vatOf(200000), 20000);
      expect(vatOf(350000), 35000);
      expect(vatOf(500000), 50000);
    });
  });

  group('SCRUM-245 - Upgrade and renewal tests', () {
    test('AT-245-08: Chưa có thuê bao thì chọn gói', () {
      expect(
        planActionLabel(basicPlan, BillingCycle.monthly, null, testPlans),
        'Chọn gói',
      );
    });

    test('AT-245-09: Gói đang dùng hiển thị Gia hạn', () {
      const current = Subscription(
        planId: 'plan-basic',
        planName: 'Cơ bản',
        cycle: BillingCycle.monthly,
        status: 'ACTIVE',
      );

      expect(
        planActionLabel(basicPlan, BillingCycle.monthly, current, testPlans),
        'Gia hạn gói',
      );
    });

    test('AT-245-10: Gói cao hơn hiển thị Nâng cấp', () {
      const current = Subscription(
        planId: 'plan-basic',
        planName: 'Cơ bản',
        cycle: BillingCycle.monthly,
        status: 'ACTIVE',
      );

      expect(
        planActionLabel(advancedPlan, BillingCycle.monthly, current, testPlans),
        'Nâng cấp gói',
      );
    });

    test('AT-245-11: Gói trọn đời đang dùng không mua lại', () {
      const current = Subscription(
        planId: 'plan-basic',
        planName: 'Cơ bản',
        cycle: BillingCycle.lifetime,
        status: 'ACTIVE',
      );

      expect(
        planActionLabel(basicPlan, BillingCycle.lifetime, current, testPlans),
        isNull,
      );
    });
  });

  group('SCRUM-245 - PlanCard widget tests', () {
    testWidgets('AT-245-12: Hiển thị giá năm', (tester) async {
      await tester.pumpWidget(
        wrap(
          PlanCard(
            plan: basicPlan,
            cycle: BillingCycle.yearly,
            actionLabel: 'Chọn gói',
            onChoose: () {},
          ),
        ),
      );

      expect(find.text('Cơ bản'), findsOneWidget);
      expect(find.text('1.920.000đ'), findsOneWidget);
      expect(find.text('/ năm'), findsOneWidget);
    });

    testWidgets('AT-245-13: Nhấn chọn gói gọi callback', (tester) async {
      var selected = false;

      await tester.pumpWidget(
        wrap(
          PlanCard(
            plan: basicPlan,
            cycle: BillingCycle.monthly,
            actionLabel: 'Chọn gói',
            onChoose: () => selected = true,
          ),
        ),
      );

      await tester.tap(find.text('Chọn gói'));

      expect(selected, isTrue);
    });

    testWidgets('AT-245-14: Gói đang sử dụng bị vô hiệu hóa', (tester) async {
      await tester.pumpWidget(
        wrap(
          PlanCard(
            plan: basicPlan,
            cycle: BillingCycle.monthly,
            actionLabel: null,
            onChoose: () {},
          ),
        ),
      );

      expect(find.text('Đang sử dụng'), findsOneWidget);

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('AT-245-15: Gói không có giá không thể chọn', (tester) async {
      await tester.pumpWidget(
        wrap(
          PlanCard(
            plan: chainPlan,
            cycle: BillingCycle.lifetime,
            actionLabel: 'Mua gói trọn đời',
            onChoose: () {},
          ),
        ),
      );

      expect(find.text('Liên hệ'), findsOneWidget);

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));

      expect(button.onPressed, isNull);
    });
  });
}
