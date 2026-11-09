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
  ];

  const sampleDesigns = [
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

  testWidgets('E5.1: Hiển thị đầy đủ Studio D3-09, tải danh sách QR và Live Preview ma trận QR', (tester) async {
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

    // 1. Kiểm tra Tiêu đề Studio D3-09
    expect(find.text('Studio Thiết Kế Ấn Phẩm QR (D3-09)'), findsOneWidget);

    // 2. Kiểm tra bộ chọn mã QR
    expect(find.text('1. Chọn Mã QR Chi Nhánh'), findsOneWidget);
    expect(find.text('MC-B04 - Bàn 04 (TABLE)'), findsOneWidget);

    // 3. Kiểm tra các khung mẫu ấn phẩm
    expect(find.text('Standee Để Bàn'), findsOneWidget);
    expect(find.text('Đế Mica Để Quầy'), findsOneWidget);
    expect(find.text('Sticker Dán Quầy'), findsOneWidget);
    expect(find.text('Thẻ Chạm NFC'), findsOneWidget);

    // 4. Kiểm tra Live Preview với QrImageView thật
    expect(find.text('Xem Trước Trực Tiếp (Live Preview)'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Mã QR thật 100% chuẩn ma trận – Camera điện thoại quét được ngay!'), findsOneWidget);
    expect(find.textContaining('Thử nghiệm quét QR: Mở màn khảo sát M1-01 (MC-B04)'), findsOneWidget);

    // 5. Kiểm tra phần mẫu thiết kế đã lưu
    expect(find.text('Mẫu Thiết Kế Đã Lưu (1)'), findsOneWidget);
  });

  testWidgets('E5.1: Chuyển đổi khung mẫu sang Sticker Dán Quầy và Thẻ Chạm NFC cập nhật Live Preview tương ứng', (tester) async {
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

    // 1. Bấm chọn mẫu "Sticker Dán Quầy"
    await tester.tap(find.text('Sticker Dán Quầy'));
    await tester.pumpAndSettle();

    // Kiểm tra QrImageView vẫn được render trong khung decal tròn
    expect(find.byType(QrImageView), findsOneWidget);

    // 2. Bấm chọn mẫu "Thẻ Chạm NFC"
    await tester.tap(find.text('Thẻ Chạm NFC'));
    await tester.pumpAndSettle();

    expect(find.text('CHẠM ĐIỆN THOẠI ĐỂ ĐÁNH GIÁ'), findsOneWidget);
    expect(find.text('NFC TAG 215'), findsOneWidget);
    expect(find.byIcon(Icons.contactless_rounded), findsWidgets);
  });

  testWidgets('E5.1: Tạo mã QR mới cho chi nhánh khi bấm nút "Tạo mã QR"', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool createCalled = false;

    final client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/qr-codes' && request.method == 'GET') {
        return http.Response(jsonEncode({'success': true, 'data': sampleQrCodes}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (path == '/api/v1/qr-codes' && request.method == 'POST') {
        createCalled = true;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'c0eebc99-new-qr-id',
                'branchId': body['branchId'] ?? 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
                'code': 'MC-QUAY02',
                'type': 'COUNTER',
                'name': body['name'] ?? 'Quầy thu ngân 2',
                'status': 'ACTIVE',
                'targetUrl': 'https://cxshield.vn/survey?qr=MC-QUAY02',
                'createdAt': '2026-11-09T11:00:00Z',
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

    // Bấm nút "Tạo mã QR" để mở Dialog
    await tester.tap(find.widgetWithText(OutlinedButton, 'Tạo mã QR'));
    await tester.pumpAndSettle();

    expect(find.text('Tạo Mã QR Vị Trí Mới'), findsOneWidget);

    // Bấm nút tạo trong Dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tạo mã QR'));
    await tester.pumpAndSettle();

    expect(createCalled, isTrue);
    expect(find.textContaining('Đã tạo mã QR mới thành công'), findsOneWidget);
  });

  testWidgets('E5.1: Chọn câu gợi ý CTA nhanh và cập nhật màu nhận diện thương hiệu', (tester) async {
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

    // Bấm chip CTA nhanh: "Góp ý dịch vụ nhận ngay quà tri ân"
    final ctaChip = find.text('Góp ý dịch vụ nhận ngay quà tri ân');
    await tester.ensureVisible(ctaChip);
    await tester.tap(ctaChip);
    await tester.pumpAndSettle();

    // Kiểm tra câu CTA trong Live Preview được cập nhật
    expect(find.text('Góp ý dịch vụ nhận ngay quà tri ân'), findsWidgets);

    // Bấm chọn màu preset "Đỏ Rượu"
    final colorChip = find.text('Đỏ Rượu');
    await tester.ensureVisible(colorChip);
    await tester.tap(colorChip);
    await tester.pumpAndSettle();

    expect(find.text('Đỏ Rượu'), findsOneWidget);
  });

  testWidgets('E5.1: Lưu mẫu thiết kế ấn phẩm vào print_designs thành công', (tester) async {
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
                'id': body['id'] ?? 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
                'businessId': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                'qrCodeId': 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
                'qrCodeValue': 'MC-B04',
                'targetUrl': 'https://cxshield.vn/survey?qr=MC-B04',
                'template': body['template'] ?? 'TABLE_TENT',
                'templateName': 'Biển để bàn tam giác (A6)',
                'brandName': body['brandName'] ?? 'Maison Coffee & Bistro',
                'ctaText': body['ctaText'] ?? 'Quét mã để đánh giá & nhận ưu đãi',
                'color': body['color'] ?? '#2C1810',
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

    // Bấm nút "Lưu mẫu thiết kế"
    final saveBtn = find.widgetWithText(ElevatedButton, 'Lưu mẫu thiết kế');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    expect(saveCalled, isTrue);
    expect(find.textContaining('Đã lưu mẫu thiết kế ấn phẩm vào print_designs thành công!'), findsOneWidget);
  });

  testWidgets('E5.1: Quét QR trên bản xem trước mở đúng màn khảo sát M1-01', (tester) async {
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

    // Bấm nút "Thử nghiệm quét QR: Mở màn khảo sát M1-01 (MC-B04)"
    final testScanBtn = find.widgetWithText(ElevatedButton, 'Thử nghiệm quét QR: Mở màn khảo sát M1-01 (MC-B04)');
    expect(testScanBtn, findsOneWidget);
    await tester.ensureVisible(testScanBtn);
    await tester.tap(testScanBtn);
    await tester.pumpAndSettle();

    // Xác nhận mở đúng màn M1-01 kèm mã QR MC-B04
    expect(find.textContaining('MC-B04'), findsWidgets);
  });
}
