import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d5_10_billing/billing_models.dart';
import 'package:cx_shield/features/d5_10_billing/subscription_page.dart';
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

void main() {
  late Map<String, Object> routes;
  late List<http.Request> requests;

  SessionController createSession({String role = 'OWNER'}) {
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

  Future<void> showPage(
    WidgetTester tester,
    Widget page, {
    void Function(String)? onGo,
  }) async {
    tester.view.physicalSize = const Size(2000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => Scaffold(body: page)),
      GoRoute(path: '/billing/plans', builder: (context, state) {
        onGo?.call('/billing/plans');
        return const Text('Trang bảng giá');
      }),
    ]);
    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
    await tester.pumpAndSettle();
  }

  setUp(() {
    requests = [];
    routes = {
      '/api/v1/businesses/biz/subscription': {
        'planId': 'p2',
        'planName': 'Nâng cao',
        'billingCycle': 'MONTHLY',
        'status': 'ACTIVE',
        'startDate': '2026-11-01',
        'endDate': '2026-12-01',
        'autoRenew': true,
        'daysRemaining': 22,
        'trialEndDate': null,
        'graceUntil': null,
        'isExpiringSoon': false,
        'isOverdue': false,
      },
      '/api/v1/businesses/biz/payments': [
        {
          'id': 'pay1',
          'businessId': 'biz',
          'planId': 'p2',
          'planName': 'Nâng cao',
          'billingCycle': 'MONTHLY',
          'transactionCode': 'CX261101001',
          'amount': 385000,
          'status': 'SUCCESS',
          'method': 'VNPAY',
          'paidAt': '2026-11-01T08:00:00Z',
          'invoiceId': 'inv1',
          'invoiceNumber': 'HD-CX261101001',
        },
        {
          'id': 'pay2',
          'businessId': 'biz',
          'planId': 'p2',
          'planName': 'Nâng cao',
          'billingCycle': 'MONTHLY',
          'transactionCode': 'CX261001001',
          'amount': 385000,
          'status': 'FAILED',
          'method': 'VNPAY',
          'createdAt': '2026-10-01T08:00:00Z',
        },
      ],
      '/api/v1/businesses/biz/invoices': [
        {
          'id': 'inv1',
          'businessId': 'biz',
          'paymentId': 'pay1',
          'transactionCode': 'CX261101001',
          'invoiceNumber': 'HD-CX261101001',
          'companyName': 'Maison Corp',
          'subtotal': 350000,
          'vatRate': 10.0,
          'vatAmount': 35000,
          'totalAmount': 385000,
          'issuedAt': '2026-11-01T08:00:00Z',
          'pdfUrl': '/api/v1/businesses/biz/invoices/inv1/pdf',
          'xmlUrl': '/api/v1/businesses/biz/invoices/inv1/xml',
        },
      ],
    };
  });

  group('Mô hình dữ liệu D5-12', () {
    test('Subscription deserialize đầy đủ trường', () {
      final sub = Subscription.fromJson({
        'planId': 'p1',
        'planName': 'Cơ bản',
        'billingCycle': 'YEARLY',
        'status': 'ACTIVE',
        'startDate': '2026-01-01',
        'endDate': '2027-01-01',
        'autoRenew': true,
        'daysRemaining': 52,
        'trialEndDate': '2026-01-15',
        'graceUntil': '2027-01-08',
        'isExpiringSoon': false,
        'isOverdue': false,
      });

      expect(sub.planName, 'Cơ bản');
      expect(sub.cycle, BillingCycle.yearly);
      expect(sub.isActive, isTrue);
      expect(sub.autoRenew, isTrue);
      expect(sub.daysRemaining, 52);
      expect(sub.isExpiringSoon, isFalse);
      expect(sub.isOverdue, isFalse);
    });

    test('PaymentHistoryItem và InvoiceItem deserialize chính xác', () {
      final pay = PaymentHistoryItem.fromJson({
        'id': 'pay1',
        'businessId': 'biz1',
        'transactionCode': 'CX100',
        'amount': 385000,
        'status': 'SUCCESS',
        'invoiceId': 'inv1',
      });

      expect(pay.isSuccess, isTrue);
      expect(pay.hasInvoice, isTrue);
      expect(pay.amount, 385000);

      final inv = InvoiceItem.fromJson({
        'id': 'inv1',
        'businessId': 'biz1',
        'paymentId': 'pay1',
        'transactionCode': 'CX100',
        'invoiceNumber': 'HD-CX100',
        'companyName': 'Công ty ABC',
        'subtotal': 350000,
        'vatRate': 10.0,
        'vatAmount': 35000,
        'totalAmount': 385000,
        'issuedAt': '2026-11-01T08:00:00Z',
        'pdfUrl': '/pdf',
        'xmlUrl': '/xml',
      });

      expect(inv.invoiceNumber, 'HD-CX100');
      expect(inv.vatAmount, 35000);
      expect(inv.totalAmount, 385000);
    });
  });

  group('Màn hình D5-12 SubscriptionPage', () {
    testWidgets('hiển thị thông tin gói hiện tại và số ngày còn lại', (tester) async {
      final session = createSession();
      await showPage(tester, SubscriptionPage(session: session));

      expect(find.text('Quản lý thuê bao & hóa đơn'), findsOneWidget);
      expect(find.text('Nâng cao'), findsWidgets);
      expect(find.text('Đang hoạt động'), findsOneWidget);
      expect(find.text('Còn 22 ngày'), findsOneWidget);
      expect(find.text('Tự động gia hạn khi đến hạn'), findsOneWidget);
    });

    testWidgets('hiển thị banner cảnh báo khi sắp hết hạn (<= 7 ngày)', (tester) async {
      routes['/api/v1/businesses/biz/subscription'] = {
        'planId': 'p2',
        'planName': 'Nâng cao',
        'billingCycle': 'MONTHLY',
        'status': 'ACTIVE',
        'startDate': '2026-10-10',
        'endDate': '2026-11-12',
        'autoRenew': false,
        'daysRemaining': 3,
        'isExpiringSoon': true,
        'isOverdue': false,
      };

      final session = createSession();
      await showPage(tester, SubscriptionPage(session: session));

      expect(find.text('Gói dịch vụ sắp hết hạn'), findsOneWidget);
      expect(find.textContaining('sẽ hết hạn trong 3 ngày nữa'), findsOneWidget);
      expect(find.text('Gia hạn ngay'), findsOneWidget);
    });

    testWidgets('hiển thị banner lỗi khi quá hạn thanh toán (overdue)', (tester) async {
      routes['/api/v1/businesses/biz/subscription'] = {
        'planId': 'p2',
        'planName': 'Nâng cao',
        'billingCycle': 'MONTHLY',
        'status': 'OVERDUE',
        'startDate': '2026-10-01',
        'endDate': '2026-11-01',
        'autoRenew': false,
        'daysRemaining': -8,
        'isExpiringSoon': false,
        'isOverdue': true,
      };

      final session = createSession();
      await showPage(tester, SubscriptionPage(session: session));

      expect(find.text('Gói dịch vụ đã quá hạn thanh toán'), findsOneWidget);
      expect(find.textContaining('đã hết hạn'), findsOneWidget);
      expect(find.text('Đã quá hạn 8 ngày'), findsOneWidget);
      expect(find.text('Quá hạn'), findsOneWidget);
    });

    testWidgets('bật tắt tự động gia hạn gọi API cập nhật', (tester) async {
      routes['/api/v1/businesses/biz/subscription/auto-renew'] = {
        'planId': 'p2',
        'planName': 'Nâng cao',
        'billingCycle': 'MONTHLY',
        'status': 'ACTIVE',
        'startDate': '2026-11-01',
        'endDate': '2026-12-01',
        'autoRenew': false,
        'daysRemaining': 22,
        'isExpiringSoon': false,
        'isOverdue': false,
      };

      final session = createSession();
      await showPage(tester, SubscriptionPage(session: session));

      // Ban đầu là bật (true), bấm switch để tắt
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      final putReq = requests.firstWhere((r) => r.method == 'PUT' && r.url.path.contains('/subscription/auto-renew'));
      expect(jsonDecode(putReq.body), {'autoRenew': false});
      expect(find.text('Đã tắt tự động gia hạn gói dịch vụ.'), findsOneWidget);
    });

    testWidgets('hiển thị bảng lịch sử giao dịch và nút tải hóa đơn PDF / XML', (tester) async {
      String? openedUrl;
      final session = createSession();
      await showPage(
        tester,
        SubscriptionPage(
          session: session,
          openUrl: (url) async => openedUrl = url,
        ),
      );

      expect(find.text('CX261101001'), findsOneWidget);
      expect(find.text('385.000đ'), findsWidgets);
      expect(find.text('Thành công'), findsOneWidget);
      expect(find.text('Thất bại'), findsOneWidget);

      // Bấm nút tải PDF
      final pdfButton = find.widgetWithText(OutlinedButton, 'PDF');
      expect(pdfButton, findsOneWidget);
      await tester.ensureVisible(pdfButton);
      await tester.tap(pdfButton);
      await tester.pumpAndSettle();
      expect(openedUrl, contains('/invoices/inv1/pdf'));

      // Bấm nút tải XML
      final xmlButton = find.widgetWithText(OutlinedButton, 'XML');
      expect(xmlButton, findsOneWidget);
      await tester.ensureVisible(xmlButton);
      await tester.tap(xmlButton);
      await tester.pumpAndSettle();
      expect(openedUrl, contains('/invoices/inv1/xml'));
    });

    testWidgets('cảnh báo quyền hạn khi không phải là OWNER', (tester) async {
      final session = createSession(role: 'BRANCH_MANAGER');
      await showPage(tester, SubscriptionPage(session: session));

      expect(
        find.text('Chỉ Chủ cơ sở được quản lý thuê bao, cài đặt gia hạn và xem hóa đơn.'),
        findsOneWidget,
      );
      final switchWidget = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.onChanged, isNull);
    });
  });
}
