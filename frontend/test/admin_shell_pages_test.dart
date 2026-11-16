import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/app/router.dart';
import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuth extends Fake implements GoTrueClient {
  final events = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => events.stream;
}

void main() {
  const routes = <String, Object>{
    '/api/v1/plans': [
      {'id': 'p1', 'name': 'Cơ bản', 'monthlyPrice': 200000, 'yearlyPrice': 1920000, 'lifetimePrice': 990000, 'features': ['A']},
    ],
    '/api/v1/businesses/biz/subscription': <String, Object>{},
    '/api/v1/businesses/biz/billing-profile': <String, Object>{},
    '/api/v1/branches/c1/google-place': {'branchId': 'c1', 'connectionStatus': 'PENDING'},
    '/api/v1/branches/c1/alert-channels': {'branchId': 'c1', 'branchName': 'Quận 1', 'channels': <Object>[]},
    '/api/v1/businesses/biz/dashboard': {
      'scanCount': 10,
      'ratedCount': 8,
      'satisfiedCount': 6,
      'satisfactionRate': 75,
      'googleRedirectCount': 5,
      'weekly': [
        {'weekStart': '2026-11-02', 'scanCount': 10, 'googleRedirectCount': 5},
      ],
    },
  };

  SessionController session() {
    final client = MockClient((request) async {
      final body = routes[request.url.path];
      return http.Response.bytes(utf8.encode(jsonEncode(body ?? {'message': 'x'})), body == null ? 404 : 200);
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
          'role': 'OWNER',
          'business': {'id': 'biz', 'brandName': 'Maison'},
        },
      ],
    });
    controller.branches = const [Branch(id: 'c1', businessId: 'biz', code: 'CN01', name: 'Quận 1')];
    controller.selectedBranch = controller.branches.first;
    controller.status = SessionStatus.ready;
    return controller;
  }

  for (final (name, size) in [('máy tính', const Size(1440, 1200)), ('điện thoại', const Size(390, 844))]) {
    for (final (path, title) in const [
      ('/dashboard', 'Tổng quan phễu đánh giá'),
      ('/alerts/channels', 'Kênh cảnh báo chi nhánh'),
      ('/billing/plans', 'Gói dịch vụ Review Funnel'),
      ('/billing/plans/checkout?planId=p1&cycle=MONTHLY', 'Thanh toán gói Cơ bản'),
    ]) {
      testWidgets('khung admin hiện $path trên $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        SharedPreferences.setMockInitialValues({});
        final theme = ThemeController(await SharedPreferences.getInstance());
        final router = createRouter(session());
        await tester.pumpWidget(ThemeScope(
          controller: theme,
          child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
        ));
        router.go(path);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(title), findsOneWidget);
      });
    }
  }
}
