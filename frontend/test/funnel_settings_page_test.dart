import 'dart:async';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d3_07_funnel_settings/funnel_settings_models.dart';
import 'package:cx_shield/features/d3_07_funnel_settings/funnel_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockApiClient extends ApiClient {
  _MockApiClient() : super(httpClient: null, baseUrl: 'http://mock');

  List<Map<String, dynamic>> keywords = [
    {
      'id': 'kw-1',
      'businessId': 'biz-1',
      'industry': 'F&B',
      'keyword': 'Cà phê đậm đà ngon',
      'active': true,
    },
    {
      'id': 'kw-2',
      'businessId': 'biz-1',
      'industry': 'F&B',
      'keyword': 'Không gian ấm cúng, view đẹp',
      'active': true,
    },
  ];

  Map<String, dynamic> routingRule = {
    'id': 'rule-1',
    'businessId': 'biz-1',
    'satisfiedMinScore': 4,
    'satisfiedMaxScore': 5,
    'publicReviewEnabled': true,
  };

  @override
  Future<dynamic> get(String path) async {
    if (path.contains('/keywords')) {
      return {'success': true, 'data': keywords};
    }
    if (path.contains('/routing-rules')) {
      return {'success': true, 'data': routingRule};
    }
    if (path.contains('/industry-templates')) {
      return {
        'success': true,
        'data': [
          {
            'industry': 'F&B',
            'displayName': 'Ẩm thực & Đồ uống (F&B)',
            'keywords': ['Cà phê ngon', 'Phục vụ nhanh'],
          }
        ]
      };
    }
    return {'success': true, 'data': null};
  }

  @override
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    if (path.contains('/keywords')) {
      final newKw = {
        'id': 'kw-${keywords.length + 1}',
        'businessId': 'biz-1',
        'industry': body['industry'] ?? 'F&B',
        'keyword': body['keyword'] ?? '',
        'active': true,
      };
      keywords.add(newKw);
      return {'success': true, 'data': newKw};
    }
    return {'success': true, 'data': null};
  }

  @override
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    if (path.contains('/routing-rules')) {
      routingRule = {
        ...routingRule,
        if (body['satisfiedMinScore'] != null) 'satisfiedMinScore': body['satisfiedMinScore'],
        if (body['publicReviewEnabled'] != null) 'publicReviewEnabled': body['publicReviewEnabled'],
      };
      return {'success': true, 'data': routingRule};
    }
    return {'success': true, 'data': null};
  }

  @override
  Future<dynamic> delete(String path) async {
    return {'success': true, 'data': null};
  }
}

class _FakeAuth extends Fake implements GoTrueClient {
  final _events = StreamController<AuthState>.broadcast();
  @override
  Stream<AuthState> get onAuthStateChange => _events.stream;
  @override
  User? get currentUser => null;
}

SessionController _makeSession({required _MockApiClient api}) {
  final session = SessionController(api: api, auth: _FakeAuth());
  session.applyProfileForTesting(
    const Me(
      userId: 'u-1',
      email: 'owner@maison.vn',
      fullName: 'Chủ quán Maison',
      onboarded: true,
      memberships: [
        Membership(
          id: 'm-1',
          role: 'OWNER',
          business: Business(
            id: 'biz-1',
            brandName: 'Maison Coffee',
            displayName: 'Maison Coffee & Bistro',
            industry: 'F&B',
            primaryColor: '#2C1810',
          ),
        ),
      ],
    ),
    loadedBranches: const [
      Branch(id: 'br-1', businessId: 'biz-1', code: 'DONGKHOI', name: 'Đồng Khởi'),
    ],
  );
  return session;
}

void main() {
  testWidgets('D3-07: Hiển thị tiêu đề, các tab Cài đặt phễu, và quy tắc phân luồng', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockApi = _MockApiClient();
    final session = _makeSession(api: mockApi);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: FunnelSettingsPage(session: session),
        ),
      ),
    );

    // Đợi tải dữ liệu ban đầu
    await tester.pumpAndSettle();

    // Xác nhận tiêu đề và tab
    expect(find.text('Cài đặt phễu: Từ khóa SEO & Ngưỡng phân luồng'), findsOneWidget);
    expect(find.text('Google Place ID (D3-05)'), findsOneWidget);
    expect(find.text('Từ khóa SEO & Phân luồng (D3-07)'), findsOneWidget);

    // Xác nhận 3 lựa chọn ngưỡng sao
    expect(find.text('4 – 5 sao (Khuyên dùng)'), findsOneWidget);
    expect(find.text('Chỉ 5 sao (Khắt khe)'), findsOneWidget);
    expect(find.text('3 – 5 sao (Mở rộng)'), findsOneWidget);

    // Xác nhận danh sách từ khóa hiển thị (ở cả bảng quản lý và Live Preview)
    expect(find.text('Cà phê đậm đà ngon'), findsWidgets);
    expect(find.text('Không gian ấm cúng, view đẹp'), findsWidgets);
  });

  testWidgets('D3-07: Thêm từ khóa mới thành công', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockApi = _MockApiClient();
    final session = _makeSession(api: mockApi);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: FunnelSettingsPage(session: session),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Nhập từ khóa mới
    final inputFinder = find.byType(TextField);
    expect(inputFinder, findsOneWidget);

    await tester.enterText(inputFinder, 'Bánh sừng bò Pháp siêu ngon');
    await tester.pump();

    // Bấm nút thêm
    final addButton = find.text('Thêm từ khóa');
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Xác nhận từ khóa mới xuất hiện trên giao diện
    expect(find.text('Bánh sừng bò Pháp siêu ngon'), findsWidgets);
  });

  testWidgets('D3-07: Thay đổi ngưỡng phân luồng sang Chỉ 5 sao', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockApi = _MockApiClient();
    final session = _makeSession(api: mockApi);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: FunnelSettingsPage(session: session),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Bấm chọn card "Chỉ 5 sao (Khắt khe)"
    final strictCard = find.text('Chỉ 5 sao (Khắt khe)');
    expect(strictCard, findsOneWidget);
    await tester.tap(strictCard);
    await tester.pumpAndSettle();

    // Kiểm tra mock API đã ghi nhận satisfiedMinScore = 5
    expect(mockApi.routingRule['satisfiedMinScore'], 5);
  });
}
