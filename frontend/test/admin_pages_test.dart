import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d4_01_alert_channels/alert_channels_page.dart';
import 'package:cx_shield/features/d5_01_dashboard/dashboard_page.dart';
import 'package:cx_shield/features/d5_10_billing/billing_models.dart';
import 'package:cx_shield/features/d5_10_billing/checkout_page.dart';
import 'package:cx_shield/features/d5_10_billing/payment_result_page.dart';
import 'package:cx_shield/features/d5_10_billing/pricing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuth extends Fake implements GoTrueClient {
  final events = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => events.stream;
}

const _planJson = [
  {
    'id': 'p1',
    'name': 'Cơ bản',
    'monthlyPrice': 200000,
    'yearlyPrice': 1920000,
    'lifetimePrice': 990000,
    'maxBranches': 1,
    'maxQrCodes': 10,
    'features': ['1 chi nhánh, tối đa 10 mã QR'],
    'includedPrintItems': '1 standee mica và 20 tem QR dán bàn',
  },
  {
    'id': 'p2',
    'name': 'Nâng cao',
    'monthlyPrice': 350000,
    'yearlyPrice': 3360000,
    'maxBranches': 1,
    'features': ['Mã QR không giới hạn'],
  },
];

void main() {
  late Map<String, Object> routes;
  late List<http.Request> requests;

  SessionController session({String role = 'OWNER'}) {
    final client = MockClient((request) async {
      requests.add(request);
      final body = routes[request.url.path];
      if (body == null) {
        return http.Response.bytes(utf8.encode('{"code":"NOT_FOUND","message":"Không tìm thấy"}'), 404);
      }
      return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
    });
    final controller = SessionController(
      api: ApiClient(baseUrl: 'http://api', accessToken: () => 'token', httpClient: client),
      auth: FakeAuth(),
    );
    controller.me = Me.fromJson({
      'userId': 'u1',
      'onboarded': true,
      'memberships': [
        {
          'membershipId': 'm1',
          'role': role,
          'business': {'id': 'biz', 'brandName': 'Maison'},
        },
      ],
    });
    controller.branches = const [Branch(id: 'c1', businessId: 'biz', code: 'CN01', name: 'Quận 1')];
    controller.selectedBranch = controller.branches.first;
    controller.status = SessionStatus.ready;
    return controller;
  }

  Future<void> show(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => Scaffold(body: page)),
      GoRoute(path: '/billing/plans/checkout', builder: (context, state) => Text('checkout ${state.uri.query}')),
      GoRoute(path: '/billing/plans', builder: (context, state) => const Text('bảng giá')),
      GoRoute(path: '/dashboard', builder: (context, state) => const Text('tổng quan')),
    ]);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
    await tester.pumpAndSettle();
  }

  setUp(() {
    requests = [];
    routes = {
      '/api/v1/plans': _planJson,
      '/api/v1/businesses/biz/subscription': <String, Object>{},
      '/api/v1/businesses/biz/billing-profile': <String, Object>{},
      '/api/v1/branches/c1/google-place': {'branchId': 'c1', 'connectionStatus': 'NOT_CONNECTED'},
    };
  });

  group('D4-01', () {
    testWidgets('hiện ba kênh và ngưỡng cảnh báo', (tester) async {
      routes['/api/v1/branches/c1/alert-channels'] = {
        'branchId': 'c1',
        'branchName': 'Quận 1',
        'thresholdStar': 4,
        'channels': [
          {'type': 'TELEGRAM', 'configured': false, 'enabled': false},
          {'type': 'ZALO', 'configured': false, 'enabled': false},
          {'type': 'EMAIL', 'configured': false, 'enabled': false},
        ],
      };

      await show(tester, AlertChannelsPage(session: session()));

      expect(find.text('Telegram Bot'), findsOneWidget);
      expect(find.text('Zalo Webhook'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.textContaining('Góp ý dưới 4 sao tại Quận 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lỗi tải có nút thử lại', (tester) async {
      await show(tester, AlertChannelsPage(session: session()));

      expect(find.text('Không tìm thấy'), findsOneWidget);
      expect(find.text('Tải lại kênh'), findsOneWidget);
    });

    testWidgets('nhân viên chỉ được xem', (tester) async {
      routes['/api/v1/branches/c1/alert-channels'] = {'branchId': 'c1', 'channels': <Object>[]};

      await show(tester, AlertChannelsPage(session: session(role: 'CS_STAFF')));

      expect(find.textContaining('Bạn chỉ có quyền xem'), findsOneWidget);
    });
  });

  group('D5-01', () {
    testWidgets('hiện số liệu và đổi bộ lọc gọi lại API', (tester) async {
      routes['/api/v1/businesses/biz/dashboard'] = {
        'scanCount': 1248,
        'ratedCount': 1000,
        'satisfactionRate': 82.5,
        'googleRedirectCount': 684,
        'weekly': [
          {'weekStart': '2026-11-02', 'scanCount': 1248, 'googleRedirectCount': 684},
        ],
      };

      await show(tester, DashboardPage(session: session()));

      expect(find.text('82,5%'), findsOneWidget);
      expect(find.text('684'), findsWidgets);
      expect(find.text('Chưa có dữ liệu'), findsNWidgets(2));
      expect(find.text('Lượt quét theo tuần'), findsOneWidget);
      expect(find.text('Phễu chuyển đổi'), findsOneWidget);

      await tester.tap(find.text('Tất cả chi nhánh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quận 1').last);
      await tester.pumpAndSettle();

      final calls = requests.where((r) => r.url.path.endsWith('/dashboard')).toList();
      expect(calls, hasLength(2));
      expect(calls.first.url.queryParameters.containsKey('branchId'), isFalse);
      expect(calls.last.url.queryParameters['branchId'], 'c1');
    });

    testWidgets('chưa có lượt quét hiện thông báo', (tester) async {
      routes['/api/v1/businesses/biz/dashboard'] = {'scanCount': 0, 'ratedCount': 0, 'googleRedirectCount': 0, 'weekly': <Object>[]};

      await show(tester, DashboardPage(session: session()));

      expect(find.text('Chưa có lượt quét nào trong khoảng thời gian này.'), findsOneWidget);
    });

    testWidgets('lỗi tải số liệu có nút thử lại', (tester) async {
      await show(tester, DashboardPage(session: session()));

      expect(find.text('Tải lại số liệu'), findsOneWidget);
    });
  });

  group('D5-10', () {
    testWidgets('hiện gói từ API và chọn gói sang màn thanh toán', (tester) async {
      await show(tester, PricingPage(session: session()));

      expect(find.text('200.000đ'), findsWidgets);
      expect(find.text('Trọn đời Cơ bản'), findsOneWidget);
      expect(find.text('So sánh giá và giới hạn các gói'), findsOneWidget);

      await tester.tap(find.text('Theo năm'));
      await tester.pumpAndSettle();
      expect(find.text('/ năm'), findsNWidgets(2));

      await tester.tap(find.text('Chọn gói').first);
      await tester.pumpAndSettle();
      expect(find.text('checkout planId=p1&cycle=YEARLY'), findsOneWidget);
    });

    testWidgets('đang có gói thì hiện gia hạn và nâng cấp', (tester) async {
      routes['/api/v1/businesses/biz/subscription'] = {
        'planId': 'p1',
        'planName': 'Cơ bản',
        'billingCycle': 'MONTHLY',
        'status': 'ACTIVE',
        'endDate': '2026-12-06',
      };

      await show(tester, PricingPage(session: session()));

      expect(find.text('Gia hạn gói'), findsOneWidget);
      expect(find.text('Nâng cấp gói'), findsOneWidget);
      expect(find.textContaining('hết hạn ngày 06/12/2026'), findsOneWidget);
    });

    testWidgets('người không phải Chủ cơ sở không mua được và không gọi API thuê bao', (tester) async {
      await show(tester, PricingPage(session: session(role: 'BRANCH_MANAGER')));

      expect(find.text('Chỉ Chủ cơ sở được mua hoặc gia hạn gói dịch vụ.'), findsOneWidget);
      expect(requests.where((r) => r.url.path.endsWith('/subscription')), isEmpty);
      expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton).first).onPressed, isNull);
    });
  });

  group('D5-11', () {
    testWidgets('tính VAT, gọi thanh toán và mở URL của VNPAY', (tester) async {
      routes['/api/v1/businesses/biz/checkouts'] = {'transactionCode': 'CX1', 'totalAmount': 385000, 'paymentUrl': 'https://pay'};
      String? opened;

      await show(
        tester,
        CheckoutPage(
          session: session(),
          planId: 'p2',
          cycle: BillingCycle.monthly,
          openPaymentUrl: (url) async => opened = url,
        ),
      );

      expect(find.text('350.000đ'), findsOneWidget);
      expect(find.text('35.000đ'), findsOneWidget);
      expect(find.text('385.000đ'), findsOneWidget);

      await tester.tap(find.text('Thanh toán 385.000đ'));
      await tester.pumpAndSettle();

      expect(opened, 'https://pay');
      final body = jsonDecode(requests.last.body) as Map<String, dynamic>;
      expect(body['billingProfile'], isNull);
      expect(body.containsKey('amount'), isFalse);
    });

    testWidgets('bật xuất hoá đơn thì bắt buộc nhập thông tin', (tester) async {
      await show(tester, CheckoutPage(session: session(), planId: 'p2', cycle: BillingCycle.monthly));

      await tester.tap(find.text('Tôi cần xuất hoá đơn VAT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thanh toán 385.000đ'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập mã số thuế.'), findsOneWidget);
      expect(find.text('Vui lòng nhập tên công ty.'), findsOneWidget);
      expect(find.text('Vui lòng nhập email nhận hoá đơn.'), findsOneWidget);
      expect(requests.where((r) => r.url.path.endsWith('/checkouts')), isEmpty);
    });

    testWidgets('điền sẵn hồ sơ hoá đơn đã lưu', (tester) async {
      routes['/api/v1/businesses/biz/billing-profile'] = {'taxCode': '0312345678', 'companyName': 'Công ty A', 'billingEmail': 'a@b.vn'};

      await show(tester, CheckoutPage(session: session(), planId: 'p2', cycle: BillingCycle.monthly));

      expect(find.text('Công ty A'), findsOneWidget);
    });

    testWidgets('lỗi cổng thanh toán hiện trên màn', (tester) async {
      await show(tester, CheckoutPage(session: session(), planId: 'p2', cycle: BillingCycle.monthly));

      await tester.tap(find.text('Thanh toán 385.000đ'));
      await tester.pumpAndSettle();

      expect(find.text('Không tìm thấy'), findsOneWidget);
    });

    testWidgets('gói hoặc chu kỳ không hợp lệ', (tester) async {
      await show(tester, CheckoutPage(session: session(), planId: 'p2', cycle: BillingCycle.lifetime));

      expect(find.text('Không tìm thấy gói đã chọn.'), findsOneWidget);
    });
  });

  group('kết quả thanh toán', () {
    testWidgets('thành công', (tester) async {
      routes['/api/v1/businesses/biz/payments/CX1'] = {
        'transactionCode': 'CX1',
        'status': 'SUCCESS',
        'amount': 385000,
        'message': 'Thanh toán thành công, gói dịch vụ đã được kích hoạt.',
      };

      await show(tester, PaymentResultPage(session: session(), transactionCode: 'CX1'));

      expect(find.text('Thanh toán thành công, gói dịch vụ đã được kích hoạt.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('thất bại', (tester) async {
      routes['/api/v1/businesses/biz/payments/CX1'] = {
        'transactionCode': 'CX1',
        'status': 'FAILED',
        'amount': 385000,
        'message': 'Bạn đã huỷ giao dịch, gói dịch vụ chưa được kích hoạt.',
      };

      await show(tester, PaymentResultPage(session: session(), transactionCode: 'CX1'));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('không có mã giao dịch hợp lệ', (tester) async {
      await show(tester, PaymentResultPage(session: session()));

      expect(find.text('Không xác nhận được kết quả giao dịch.'), findsOneWidget);
      await tester.tap(find.text('Mở trang Tổng quan'));
      await tester.pumpAndSettle();
      expect(find.text('tổng quan'), findsOneWidget);
    });
  });
}
