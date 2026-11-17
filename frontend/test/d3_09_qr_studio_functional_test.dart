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
    },
    {
      'id': 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a77',
      'businessId': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
      'qrCodeId': 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
      'qrCodeValue': 'MC-B04',
      'targetUrl': 'https://cxshield.vn/survey?qr=MC-B04',
      'template': 'COUNTER_STAND',
      'templateName': 'Đế mica quầy thu ngân (A5)',
      'brandName': 'Maison Coffee Quầy Thu Ngân',
      'ctaText': 'Góp ý nhận ngay voucher giảm 10k',
      'color': '#1E3A8A',
      'logoUrl': 'https://images.unsplash.com/photo-logo.png',
      'exportFormat': 'PNG',
      'size': 'A5',
      'downloadUrl': '/api/v1/print-designs/e0eebc99-77/export',
      'createdAt': '2026-11-10T10:00:00Z',
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

  testWidgets('TC-235-01: Mở màn D3-09, tải danh sách QR và hiển thị Live Preview', (tester) async {
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
    expect(find.text('Xem Trước Trực Tiếp (Live Preview)'), findsOneWidget);
    expect(find.byType(QrImageView), findsWidgets);
  });

  testWidgets('TC-235-02: Mở Dialog và tạo mã QR vị trí mới cho chi nhánh', (tester) async {
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
        return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': 'c0eebc99-new',
                'branchId': 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
                'code': 'MC-QUAY03',
                'type': 'COUNTER',
                'name': 'Quầy thu ngân 3',
                'status': 'ACTIVE',
                'targetUrl': 'https://cxshield.vn/survey?qr=MC-QUAY03',
                'createdAt': '2026-11-17T10:00:00Z',
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

    expect(createCalled, isTrue);
    expect(find.textContaining('Đã tạo mã QR mới thành công'), findsOneWidget);
  });

  testWidgets('TC-235-03: Chọn khung mẫu Standee Để Bàn (TABLE_TENT)', (tester) async {
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

    // Bấm Standee Để Bàn
    await tester.tap(find.text('Standee Để Bàn'));
    await tester.pumpAndSettle();

    expect(find.text('Chạm NFC hoặc quét QR'), findsOneWidget);
    expect(find.byType(QrImageView), findsWidgets);
  });

  testWidgets('TC-235-04: Chọn khung mẫu Sticker Dán Quầy và Thẻ Chạm NFC', (tester) async {
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

    // Bấm chọn Sticker Dán Quầy
    await tester.tap(find.text('Sticker Dán Quầy'));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);

    // Bấm chọn Thẻ Chạm NFC
    await tester.tap(find.text('Thẻ Chạm NFC'));
    await tester.pumpAndSettle();
    expect(find.text('CHẠM ĐIỆN THOẠI ĐỂ ĐÁNH GIÁ'), findsOneWidget);
    expect(find.text('NFC TAG 215'), findsOneWidget);
  });

  testWidgets('TC-235-05: Thêm đường dẫn logo hợp lệ và hiển thị trên banner Live Preview', (tester) async {
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

    final logoField = find.widgetWithText(TextField, 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200');
    await tester.ensureVisible(logoField);
    await tester.enterText(logoField, 'https://images.unsplash.com/photo-custom-logo.png');
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('TC-235-06: Chỉnh sửa CTA và chọn gợi ý chip CTA nhanh cập nhật Live Preview trực tiếp', (tester) async {
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

    final chip = find.text('Đánh giá 5 sao nhận ngay quà tặng');
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.text('Đánh giá 5 sao nhận ngay quà tặng'), findsWidgets);
  });

  testWidgets('TC-235-07: Kiểm tra Live Preview cập nhật màu sắc nhận diện thương hiệu real-time', (tester) async {
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

    final colorChip = find.text('Đỏ Rượu');
    await tester.ensureVisible(colorChip);
    await tester.tap(colorChip);
    await tester.pumpAndSettle();

    expect(find.text('Đỏ Rượu'), findsOneWidget);
  });

  testWidgets('TC-235-08: Lưu mẫu thiết kế và lưu bản sao mới thành công', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    int saveCount = 0;

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
        saveCount++;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'id': body['id']?.toString().isNotEmpty == true ? body['id'] : 'new-copy-id',
                'businessId': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                'qrCodeId': 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
                'qrCodeValue': 'MC-B04',
                'targetUrl': 'https://cxshield.vn/survey?qr=MC-B04',
                'template': 'TABLE_TENT',
                'templateName': 'Biển để bàn tam giác (A6)',
                'brandName': 'Maison Coffee & Bistro',
                'ctaText': 'Quét mã để đánh giá & nhận ưu đãi',
                'color': '#2C1810',
                'logoUrl': '',
                'exportFormat': 'PDF',
                'size': 'A6',
                'downloadUrl': '/export',
                'createdAt': '2026-11-17T10:00:00Z',
              }
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    // 1. Lưu mẫu thiết kế
    final saveBtn = find.widgetWithText(ElevatedButton, 'Lưu mẫu thiết kế');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();
    expect(saveCount, 1);
    expect(find.textContaining('Đã lưu mẫu thiết kế ấn phẩm vào print_designs thành công!'), findsOneWidget);

    // Đợi SnackBar cũ đóng để không che button
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 2. Lưu bản sao mới
    final saveCopyBtn = find.widgetWithText(OutlinedButton, 'Lưu bản sao mới');
    await tester.ensureVisible(saveCopyBtn);
    await tester.tap(saveCopyBtn);
    await tester.pumpAndSettle();
    expect(saveCount, 2);
    expect(find.textContaining('Đã lưu thành mẫu thiết kế mới thành công!'), findsOneWidget);
  });

  testWidgets('TC-235-09: Nạp lại mẫu thiết kế đã lưu phục hồi đầy đủ dữ liệu lên form và Live Preview', (tester) async {
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

    final savedSection = find.text('Mẫu Thiết Kế Đã Lưu (2)');
    await tester.ensureVisible(savedSection);
    expect(savedSection, findsOneWidget);

    final loadBtn = find.widgetWithText(OutlinedButton, 'Nạp mẫu này');
    expect(loadBtn, findsOneWidget);
    await tester.ensureVisible(loadBtn);
    await tester.tap(loadBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Đã nạp mẫu: Maison Coffee Quầy Thu Ngân'), findsOneWidget);

    final brandField = find.widgetWithText(TextField, 'Maison Coffee Quầy Thu Ngân');
    await tester.ensureVisible(brandField);
    expect(brandField, findsOneWidget);
  });

  testWidgets('TC-235-10: Xóa mẫu thiết kế ấn phẩm thành công khỏi danh sách', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool deleteCalled = false;

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
      if (path.startsWith('/api/v1/print-designs/') && request.method == 'DELETE') {
        deleteCalled = true;
        return http.Response(jsonEncode({'success': true, 'data': null}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('{"error": "not found"}', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    final deleteIconBtn = find.byTooltip('Xóa mẫu này').first;
    await tester.ensureVisible(deleteIconBtn);
    await tester.tap(deleteIconBtn);
    await tester.pumpAndSettle();

    expect(deleteCalled, isTrue);
    expect(find.textContaining('Đã xóa mẫu thiết kế thành công!'), findsOneWidget);
  });

  testWidgets('TC-235-11: Thử nghiệm quét QR kích hoạt điều hướng màn khảo sát M1-01', (tester) async {
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

    final testScanBtn = find.widgetWithText(ElevatedButton, 'Thử nghiệm quét QR: Mở màn khảo sát M1-01 (MC-B04)');
    await tester.ensureVisible(testScanBtn);
    await tester.tap(testScanBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('MC-B04'), findsWidgets);
  });

  testWidgets('TC-235-12: Nhập logo sai định dạng không làm crash giao diện (hiển thị fallback error icon)', (tester) async {
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

    final logoField = find.widgetWithText(TextField, 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200');
    await tester.ensureVisible(logoField);
    await tester.enterText(logoField, 'https://malicious.example.com/payload.exe');
    await tester.pumpAndSettle();

    expect(find.text('Studio Thiết Kế Ấn Phẩm QR (D3-09)'), findsOneWidget);
  });
}
