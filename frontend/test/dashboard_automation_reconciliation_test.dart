import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/app/router.dart';
import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d5_01_dashboard/dashboard_models.dart';
import 'package:cx_shield/features/d5_01_dashboard/dashboard_page.dart';
import 'package:cx_shield/features/d5_01_dashboard/dashboard_widgets.dart';
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
  late Map<String, dynamic> responsesByQuery;
  late List<http.Request> requests;

  final sampleAllBranchesData = {
    'scanCount': 15,
    'ratedCount': 13,
    'satisfiedCount': 10,
    'satisfactionRate': 76.9,
    'googleRedirectCount': 7,
    'googleReviewCount': 450,
    'googleAvgRating': 4.7,
    'weekly': [
      {
        'weekStart': '2026-10-26',
        'scanCount': 7,
        'satisfactionRate': 71.4,
        'googleRedirectCount': 3,
        'googleReviewCount': 440,
        'googleAvgRating': 4.6,
      },
      {
        'weekStart': '2026-11-02',
        'scanCount': 8,
        'satisfactionRate': 83.3,
        'googleRedirectCount': 4,
        'googleReviewCount': 450,
        'googleAvgRating': 4.7,
      },
    ],
  };

  final sampleBranch1Data = {
    'scanCount': 10,
    'ratedCount': 8,
    'satisfiedCount': 5,
    'satisfactionRate': 62.5,
    'googleRedirectCount': 4,
    'googleReviewCount': 300,
    'googleAvgRating': 4.5,
    'weekly': [
      {'weekStart': '2026-11-02', 'scanCount': 10, 'satisfactionRate': 62.5, 'googleRedirectCount': 4},
    ],
  };

  final sampleBranch2Data = {
    'scanCount': 5,
    'ratedCount': 5,
    'satisfiedCount': 5,
    'satisfactionRate': 100.0,
    'googleRedirectCount': 3,
    'googleReviewCount': 150,
    'googleAvgRating': 5.0,
    'weekly': [
      {'weekStart': '2026-11-02', 'scanCount': 5, 'satisfactionRate': 100.0, 'googleRedirectCount': 3},
    ],
  };

  final sampleEmptyBranchData = {
    'scanCount': 0,
    'ratedCount': 0,
    'satisfiedCount': 0,
    'satisfactionRate': null,
    'googleRedirectCount': 0,
    'weekly': <Object>[],
  };

  SessionController createSession({String role = 'OWNER'}) {
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path.contains('/google-place')) {
        final segments = request.url.pathSegments;
        final bIdx = segments.indexOf('branches');
        final branchId = bIdx != -1 && bIdx + 1 < segments.length ? segments[bIdx + 1] : 'c1';
        final body = {
          'branchId': branchId,
          'branchName': 'Chi nhánh $branchId',
          'connectionStatus': 'NOT_CONNECTED',
          'googleVerificationEnabled': false,
        };
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      }

      final branchId = request.url.queryParameters['branchId'];
      Map<String, dynamic>? body;
      if (branchId == 'c1') {
        body = sampleBranch1Data;
      } else if (branchId == 'c2') {
        body = sampleBranch2Data;
      } else if (branchId == 'c3') {
        body = sampleEmptyBranchData;
      } else {
        body = responsesByQuery['all'] ?? sampleAllBranchesData;
      }
      return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
    });

    final controller = SessionController(
      api: ApiClient(baseUrl: 'http://api', accessToken: () => 'mock-jwt-token', httpClient: client),
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
    controller.branches = const [
      Branch(id: 'c1', businessId: 'biz', code: 'CN01', name: 'Quận 1'),
      Branch(id: 'c2', businessId: 'biz', code: 'CN02', name: 'Quận 3'),
      Branch(id: 'c3', businessId: 'biz', code: 'CN03', name: 'Thủ Đức'),
    ];
    controller.selectedBranch = controller.branches.first;
    controller.status = SessionStatus.ready;
    return controller;
  }

  Future<void> pumpDashboard(WidgetTester tester, SessionController sessionCtrl) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => Scaffold(body: DashboardPage(session: sessionCtrl))),
      GoRoute(path: '/funnel/google-place', builder: (context, state) => const Text('Màn hình Google Place')),
    ]);

    await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
    await tester.pumpAndSettle();
  }

  setUp(() {
    requests = [];
    responsesByQuery = {};
  });

  group('SCRUM-242: Automation Data Reconciliation & Formulas', () {
    testWidgets('TC-D501-REC-01: Đối chiếu số liệu hiển thị trên thẻ và phễu với tập khảo sát mẫu', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      // Thẻ 1: Lượt quét QR
      expect(find.text('15'), findsOneWidget);
      // Thẻ 2: Hài lòng 4-5 sao & note
      expect(find.text('76,9%'), findsOneWidget);
      expect(find.text('13 lượt đánh giá'), findsOneWidget);
      // Thẻ 3: Chuyển sang Google
      expect(find.text('7'), findsWidgets);
      // Thẻ 4: Đánh giá Google
      expect(find.text('450'), findsWidgets);
      // Thẻ 5: Điểm sao Google
      expect(find.text('4,7★'), findsWidgets);

      // Phễu chuyển đổi 4 bước
      expect(find.text('Quét mã QR'), findsOneWidget);
      expect(find.text('15 · 100%'), findsOneWidget);
      expect(find.text('13 · 86,7%'), findsOneWidget);
      expect(find.text('10 · 66,7%'), findsOneWidget);
      expect(find.text('7 · 46,7%'), findsOneWidget);

      // Subtitle hiển thị chuẩn brandName và thời gian
      expect(find.text('Maison · 8 tuần gần nhất'), findsOneWidget);
    });

    testWidgets('TC-D501-REC-02: Phễu chuyển đổi tính đúng tỷ lệ trên mẫu số lượt quét 15', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      final barStep4 = tester.widget<LinearProgressIndicator>(
        find.byKey(const ValueKey('funnel-Chuyển sang Google')),
      );
      expect(barStep4.value, closeTo(7 / 15, 0.001));

      final barStep3 = tester.widget<LinearProgressIndicator>(
        find.byKey(const ValueKey('funnel-Hài lòng 4–5 sao')),
      );
      expect(barStep3.value, closeTo(10 / 15, 0.001));
    });
  });

  group('SCRUM-242: Automation Branch Filter', () {
    testWidgets('TC-D501-FLT-AUT-01: Lọc chi nhánh Quận 1 cập nhật số liệu và note chính xác', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      // Chuyển sang Quận 1 (c1)
      await tester.tap(find.text('Tất cả chi nhánh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quận 1').last);
      await tester.pumpAndSettle();

      // Kiểm tra request gọi lại API
      final calls = requests.where((r) => r.url.path.endsWith('/dashboard')).toList();
      expect(calls.last.url.queryParameters['branchId'], 'c1');

      // Số liệu cập nhật theo chi nhánh 1 (10 scans, 8 ratings, 62.5% satisfaction)
      expect(find.text('10'), findsWidgets);
      expect(find.text('62,5%'), findsWidgets);
      expect(find.text('8 lượt đánh giá'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('300'), findsWidgets);
      expect(find.text('4,5★'), findsWidgets);
    });

    testWidgets('TC-D501-FLT-AUT-02: Lọc chi nhánh Quận 3 (100% hài lòng) và quay lại Tất cả', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      // Chuyển sang Quận 3 (c2)
      await tester.tap(find.text('Tất cả chi nhánh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quận 3').last);
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsWidgets);
      expect(find.text('5 lượt đánh giá'), findsOneWidget);

      // Chuyển lại về Tất cả chi nhánh
      await tester.tap(find.text('Quận 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tất cả chi nhánh').last);
      await tester.pumpAndSettle();

      final calls = requests.where((r) => r.url.path.endsWith('/dashboard')).toList();
      expect(calls.last.url.queryParameters.containsKey('branchId'), isFalse);
      expect(find.text('76,9%'), findsWidgets);
    });

    testWidgets('TC-D501-FLT-AUT-03: Lọc chi nhánh Thủ Đức (chưa có dữ liệu) hiển thị banner rỗng và ẩn biểu đồ', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      // Chuyển sang Thủ Đức (c3 - 0 scans)
      await tester.tap(find.text('Tất cả chi nhánh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thủ Đức').last);
      await tester.pumpAndSettle();

      expect(find.text('Chưa có lượt quét nào trong khoảng thời gian này.'), findsOneWidget);
      expect(find.byType(FunnelChart), findsNothing);
      expect(find.byType(WeeklyBarChart), findsNothing);
      expect(find.byType(WeeklyTable), findsNothing);
    });
  });

  group('SCRUM-242: Automation Date Range Filter', () {
    testWidgets('TC-D501-DATE-AUT-01: Đổi khoảng thời gian 4 tuần cập nhật subtitle và query params', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      expect(find.text('8 tuần gần nhất'), findsOneWidget);

      // Chọn 4 tuần gần nhất
      await tester.tap(find.text('8 tuần gần nhất'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4 tuần gần nhất').last);
      await tester.pumpAndSettle();

      expect(find.text('Maison · 4 tuần gần nhất'), findsOneWidget);

      final calls = requests.where((r) => r.url.path.endsWith('/dashboard')).toList();
      final fromStr = calls.last.url.queryParameters['from']!;
      final toStr = calls.last.url.queryParameters['to']!;
      final fromDate = DateTime.parse(fromStr);
      final toDate = DateTime.parse(toStr);
      expect(toDate.difference(fromDate).inDays, 28);
    });

    testWidgets('TC-D501-DATE-AUT-02: Đổi khoảng thời gian 12 tuần cập nhật subtitle và query params', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      // Chọn 12 tuần gần nhất
      await tester.tap(find.text('8 tuần gần nhất'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('12 tuần gần nhất').last);
      await tester.pumpAndSettle();

      expect(find.text('Maison · 12 tuần gần nhất'), findsOneWidget);

      final calls = requests.where((r) => r.url.path.endsWith('/dashboard')).toList();
      final fromStr = calls.last.url.queryParameters['from']!;
      final toStr = calls.last.url.queryParameters['to']!;
      final fromDate = DateTime.parse(fromStr);
      final toDate = DateTime.parse(toStr);
      expect(toDate.difference(fromDate).inDays, 84);
    });
  });

  group('SCRUM-242: Automation Navigation & Guards', () {
    test('TC-D501-NAV-AUT-01: Chặn vào /dashboard khi chưa đăng nhập (signedOut -> /login)', () {
      final result = sessionRedirect(SessionStatus.signedOut, false, Uri.parse('http://localhost:3000/dashboard'));
      expect(result, '/login');
    });

    test('TC-D501-NAV-AUT-02: Chặn vào /dashboard khi chưa hoàn tất cơ sở (onboarded=false -> /onboarding)', () {
      final result = sessionRedirect(SessionStatus.ready, false, Uri.parse('http://localhost:3000/dashboard'));
      expect(result, '/onboarding');
    });

    test('TC-D501-NAV-AUT-03: Mở root / tự động chuyển hướng vào /dashboard khi đã onboarded', () {
      final result = sessionRedirect(SessionStatus.ready, true, Uri.parse('http://localhost:3000/'));
      expect(result, '/dashboard');
    });

    testWidgets('TC-D501-NAV-AUT-04: Nút "Mở cấu hình Google" chuyển hướng tới /funnel/google-place', (tester) async {
      final session = createSession();
      await pumpDashboard(tester, session);

      await tester.tap(find.text('Mở cấu hình Google'));
      await tester.pumpAndSettle();

      expect(find.text('Màn hình Google Place'), findsOneWidget);
    });
  });
}
