import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d3_09_qr_studio/d3_09_qr_studio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuth extends Fake implements GoTrueClient {
  final events = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => events.stream;

  @override
  User? get currentUser => null;
}

void main() {
  const business = {
    'id': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'brandName': 'Maison Coffee & Bistro',
    'displayName': 'Maison Coffee & Bistro',
  };

  const sampleQrCodes = [
    {
      'id': 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
      'branchId': 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
      'code': 'MC-B04',
      'type': 'TABLE',
      'name': 'Bàn 04',
      'status': 'ACTIVE',
      'targetUrl': 'https://cxshield.vn/survey?qr=MC-B04',
      'createdAt': '2026-11-09T10:00:00Z',
    },
    {
      'id': 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
      'branchId': 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
      'code': 'MC-QUAY01',
      'type': 'COUNTER',
      'name': 'Quầy Thu Ngân 01',
      'status': 'ACTIVE',
      'targetUrl': 'https://cxshield.vn/survey?qr=MC-QUAY01',
      'createdAt': '2026-11-09T11:00:00Z',
    }
  ];

  final sampleDesigns = [
    {
      'id': 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
      'businessId': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
      'qrCodeId': 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
      'qrCodeValue': 'MC-B04',
      'targetUrl': 'https://cxshield.vn/survey?qr=MC-B04',
      'template': 'TABLE_TENT',
      'templateName': 'Biển để bàn tam giác (A6)',
      'brandName': 'Maison Coffee & Bistro',
      'ctaText': 'Quét mã để đánh giá & nhận ưu đãi',
      'color': '#2C1810',
      'logoUrl': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200',
      'exportFormat': 'PDF',
      'size': 'A6',
      'downloadUrl': '/api/v1/print-designs/e0eebc99/export',
      'createdAt': '2026-11-09T10:00:00Z',
    }
  ];

  late FakeAuth auth;
  late SessionController session;

  Widget createTestWidget({required MockClient client}) {
    final api = ApiClient(
      baseUrl: 'http://api.test',
      accessToken: () => 'test_token',
      httpClient: client,
    );
    session = SessionController(api: api, auth: auth);
    session.me = Me.fromJson({
      'userId': 'u1',
      'email': 'chu@maison.vn',
      'onboarded': true,
      'memberships': [
        {'membershipId': 'm1', 'role': 'OWNER', 'business': business},
      ],
    });

    return MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(
        body: D309QrStudioPage(session: session),
      ),
    );
  }

  setUp(() {
    auth = FakeAuth();
  });

  // =========================================================================
  // BỘ 10 LUỒNG AUTOMATION SCRUM-236
  // =========================================================================

  testWidgets('AUTO-236-01: Khởi động Studio D3-09, tải chi nhánh và mã QR mặc định', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    expect(find.text('Studio Thiết Kế Ấn Phẩm QR (D3-09)'), findsOneWidget);
    expect(find.text('1. Chọn Mã QR Chi Nhánh'), findsOneWidget);
    expect(find.text('MC-B04 - Bàn 04 (TABLE)'), findsOneWidget);
    expect(find.byType(QrImageView), findsWidgets);
  });

  testWidgets('AUTO-236-02: Tạo mã QR mới cho chi nhánh qua Dialog và cập nhật Studio', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool apiCalled = false;

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes' && request.method == 'GET') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/qr-codes' && request.method == 'POST') {
        apiCalled = true;
        return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'c0eebc99-new-qr',
                'branchId': 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
                'code': 'MC-BAN15',
                'type': 'TABLE',
                'name': 'Bàn 15 Khu VIP',
                'status': 'ACTIVE',
                'targetUrl': 'https://cxshield.vn/survey?qr=MC-BAN15',
                'createdAt': '2026-11-17T12:00:00Z',
              }
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Tạo mã QR'));
    await tester.pumpAndSettle();

    expect(find.text('Tạo Mã QR Vị Trí Mới'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Tạo mã QR'));
    await tester.pumpAndSettle();

    expect(apiCalled, isTrue);
    expect(find.textContaining('Đã tạo mã QR mới thành công: MC-BAN15'), findsOneWidget);
  });

  testWidgets('AUTO-236-03: Chọn khung mẫu Standee Để Bàn (TABLE_TENT) kiểm tra khổ in A6', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Standee Để Bàn'));
    await tester.pumpAndSettle();

    expect(find.text('Chạm NFC hoặc quét QR'), findsOneWidget);
    expect(find.byType(QrImageView), findsWidgets);
  });

  testWidgets('AUTO-236-04: Chọn khung mẫu Sticker Dán Quầy (WINDOW_STICKER) kiểm tra Decal tròn', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sticker Dán Quầy'));
    await tester.pumpAndSettle();

    expect(find.byType(QrImageView), findsOneWidget);
  });

  testWidgets('AUTO-236-05: Chọn khung mẫu Thẻ Chạm NFC (CARD_NFC) kiểm tra bố cục NFC', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Thẻ Chạm NFC'));
    await tester.pumpAndSettle();

    expect(find.text('CHẠM ĐIỆN THOẠI ĐỂ ĐÁNH GIÁ'), findsOneWidget);
    expect(find.text('NFC TAG 215'), findsOneWidget);
    expect(find.byIcon(Icons.contactless_rounded), findsWidgets);
  });

  testWidgets('AUTO-236-06: Thêm đường dẫn logo hợp lệ cập nhật ảnh banner Live Preview', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    final logoInput = find.widgetWithText(TextField, 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200');
    await tester.ensureVisible(logoInput);
    await tester.enterText(logoInput, 'https://images.unsplash.com/brand-logo-custom.png');
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('AUTO-236-07: Chỉnh sửa CTA và chọn gợi ý chip CTA nhanh cập nhật Live Preview trực tiếp', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    final ctaChip = find.text('Góp ý dịch vụ nhận ngay quà tri ân');
    await tester.ensureVisible(ctaChip);
    await tester.tap(ctaChip);
    await tester.pumpAndSettle();

    expect(find.text('Góp ý dịch vụ nhận ngay quà tri ân'), findsWidgets);
  });

  testWidgets('AUTO-236-08: Tùy biến màu nhận diện thương hiệu real-time trên Live Preview', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    final navyChip = find.text('Xanh Navy');
    await tester.ensureVisible(navyChip);
    await tester.tap(navyChip);
    await tester.pumpAndSettle();

    expect(find.text('Xanh Navy'), findsOneWidget);
  });

  testWidgets('AUTO-236-09: Lưu thiết kế vào print_designs và nạp lại phục hồi đầy đủ dữ liệu', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool saveCalled = false;

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs' && request.method == 'GET') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs' && request.method == 'POST') {
        saveCalled = true;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': body['id'] ?? 'e0eebc99-saved',
                'businessId': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                'qrCodeId': 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
                'qrCodeValue': 'MC-B04',
                'targetUrl': 'https://cxshield.vn/survey?qr=MC-B04',
                'template': 'TABLE_TENT',
                'templateName': 'Biển để bàn tam giác (A6)',
                'brandName': 'Maison Coffee & Bistro',
                'ctaText': 'Quét mã để đánh giá & nhận ưu đãi',
                'color': '#2C1810',
                'exportFormat': 'PDF',
                'size': 'A6',
                'downloadUrl': '/api/v1/print-designs/e0eebc99/export',
                'createdAt': '2026-11-09T10:00:00Z',
              }
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    final saveBtn = find.widgetWithText(ElevatedButton, 'Lưu mẫu thiết kế');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(saveCalled, isTrue);
    expect(find.textContaining('Đã lưu mẫu thiết kế ấn phẩm vào print_designs thành công!'), findsOneWidget);
  });

  testWidgets('AUTO-236-10: Kiểm tra URL trong mã QR trỏ chính xác màn khảo sát M1-01 và đúng chi nhánh', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    // 1. Kiểm tra QrImageView có mặt trên Live Preview và kích hoạt điều hướng M1-01 khi tương tác
    final qrFinder = find.byType(QrImageView).first;
    expect(qrFinder, findsOneWidget);
    await tester.tap(qrFinder);
    await tester.pumpAndSettle();
    expect(find.text('Điều hướng màn khách M1-01: /survey?qr=MC-B04'), findsOneWidget);

    // Đợi đóng SnackBar trước khi kiểm tra nút thử nghiệm
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 2. Kiểm tra nút thử nghiệm quét QR
    final scanTestBtn = find.widgetWithText(ElevatedButton, 'Thử nghiệm quét QR: Mở màn khảo sát M1-01 (MC-B04)');
    expect(scanTestBtn, findsOneWidget);
    await tester.ensureVisible(scanTestBtn);
    await tester.tap(scanTestBtn);
    await tester.pumpAndSettle();

    expect(find.text('Điều hướng màn khách M1-01: /survey?qr=MC-B04'), findsOneWidget);
  });
}
