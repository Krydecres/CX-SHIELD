import 'dart:async';
import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d3_11_print_nfc/d3_11_print_nfc_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
      'exportFormat': 'PDF',
      'size': 'A6',
      'downloadUrl': '/api/v1/print-designs/e0eebc99/export',
      'createdAt': '2026-11-09T10:00:00Z',
    }
  ];

  const sampleOrders = [
    {
      'id': 'f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a66',
      'businessId': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
      'designId': 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
      'material': 'WOOD',
      'materialLabel': 'Thẻ gỗ Walnut sang trọng',
      'quantity': 10,
      'unitPrice': 45000,
      'totalAmount': 450000,
      'shipName': 'Nguyễn Văn Chủ',
      'shipPhone': '0901234567',
      'shipAddress': '123 Đồng Khởi, Bến Nghé, Quận 1',
      'status': 'PENDING',
      'statusLabel': 'Mới tiếp nhận',
      'estimatedDelivery': '2-3 ngày làm việc',
      'createdAt': '2026-11-09T10:30:00Z',
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
      home: D311PrintNfcPage(session: session),
    );
  }

  setUp(() {
    auth = FakeAuth();
  });

  testWidgets('E5.3: Hiển thị đầy đủ giao diện D3-11 xuất file in ấn và xem Live Preview', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((req) async {
      if (req.url.path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (req.url.path == '/api/v1/nfc-orders') {
        return http.Response(jsonEncode({'success': true, 'data': sampleOrders}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    // 1. Kiểm tra header & badge mã màn hình D3-11
    expect(find.text('D3-11 • Ấn phẩm QR / NFC'), findsOneWidget);
    expect(find.text('Chuẩn in ấn ≥ 300 DPI'), findsOneWidget);
    expect(find.text('Xuất file in ấn chất lượng cao & Đặt phôi thẻ NFC'), findsOneWidget);

    // 2. Kiểm tra tab
    expect(find.text('Xuất file in ấn (PDF / PNG)'), findsOneWidget);
    expect(find.text('Đặt phôi thẻ NFC vật lý'), findsOneWidget);
    expect(find.textContaining('Lịch sử đơn hàng'), findsOneWidget);

    // 3. Kiểm tra form tùy chỉnh
    expect(find.textContaining('Vị trí đặt / Mã QR nguồn', findRichText: true), findsOneWidget);
    expect(find.textContaining('Tên thương hiệu hiển thị', findRichText: true), findsOneWidget);
    expect(find.text('Maison Coffee & Bistro'), findsWidgets);
    expect(find.text('Quét mã để đánh giá & nhận ưu đãi'), findsWidgets);

    // 4. Kiểm tra nút tải file in ấn
    expect(find.textContaining('Tải File In Ấn'), findsOneWidget);
    expect(find.text('Lưu thiết kế'), findsOneWidget);

    // 5. Kiểm tra Live Preview
    expect(find.textContaining('Mô phỏng bản in thực tế'), findsOneWidget);
    expect(find.text('MÃ: MC-B04'), findsOneWidget);
    expect(find.text('Chạm NFC hoặc quét QR'), findsOneWidget);
  });

  testWidgets('E5.3: Chuyển Tab Đặt phôi thẻ NFC và kiểm tra tính toán tổng tiền theo chất liệu & số lượng', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((req) async {
      if (req.url.path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (req.url.path == '/api/v1/nfc-orders') {
        return http.Response(jsonEncode({'success': true, 'data': sampleOrders}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    // Chuyển sang Tab 2: Đặt phôi thẻ NFC vật lý
    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    // Kiểm tra chất liệu Thẻ Gỗ và Thẻ Mica
    expect(find.text('Thẻ Gỗ Walnut sang trọng'), findsOneWidget);
    expect(find.text('Thẻ Mica Acrylic trong suốt'), findsOneWidget);
    expect(find.text('45.000 đ / thẻ'), findsWidgets);
    expect(find.text('35.000 đ / thẻ'), findsOneWidget);

    // Mặc định 10 thẻ Gỗ = 450.000 đ
    expect(find.text('Tạm tính: 450.000 đ'), findsOneWidget);

    // Chọn Thẻ Mica
    await tester.tap(find.text('Thẻ Mica Acrylic trong suốt'));
    await tester.pumpAndSettle();

    // 10 thẻ Mica = 350.000 đ
    expect(find.text('Tạm tính: 350.000 đ'), findsOneWidget);

    // Bấm tăng số lượng lên 11 thẻ -> 11 * 35.000 = 385.000 đ
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('11'), findsOneWidget);
    expect(find.text('Tạm tính: 385.000 đ'), findsOneWidget);
  });

  testWidgets('E5.3: Kiểm tra Validation dữ liệu form đặt thẻ NFC (SĐT Việt Nam, địa chỉ, họ tên)', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final client = MockClient((req) async {
      if (req.url.path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (req.url.path == '/api/v1/nfc-orders') {
        return http.Response(jsonEncode({'success': true, 'data': sampleOrders}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    // Chuyển sang Tab 2
    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    // Bấm nút gửi đơn khi chưa nhập gì
    final submitButton = find.text('Gửi Đơn Đặt Mua Phôi Thẻ NFC');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Kiểm tra thông báo lỗi validation
    expect(find.text('Vui lòng nhập họ và tên người nhận'), findsOneWidget);
    expect(find.text('Vui lòng nhập số điện thoại nhận hàng'), findsOneWidget);
    expect(find.text('Vui lòng nhập địa chỉ giao hàng chi tiết (tối thiểu 5 ký tự)'), findsOneWidget);

    // Nhập SĐT sai định dạng
    final phoneField = find.widgetWithText(TextFormField, 'VD: 0901234567 hoặc 0987654321');
    await tester.enterText(phoneField, '123456');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('Số điện thoại không đúng định dạng Việt Nam'), findsOneWidget);
  });

  testWidgets('E5.3: Gửi đơn đặt phôi thẻ NFC thành công và xem trong Lịch sử đơn hàng', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final newOrderResponse = {
      'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
      'businessId': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
      'designId': 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55',
      'material': 'WOOD',
      'materialLabel': 'Thẻ gỗ Walnut sang trọng',
      'quantity': 10,
      'unitPrice': 45000,
      'totalAmount': 450000,
      'shipName': 'Lê Văn An',
      'shipPhone': '0988776655',
      'shipAddress': '99 Hai Bà Trưng, Quận 1, TP. HCM',
      'status': 'PENDING',
      'statusLabel': 'Mới tiếp nhận',
      'estimatedDelivery': '2-3 ngày làm việc',
      'createdAt': '2026-11-09T11:00:00Z',
    };

    final client = MockClient((req) async {
      if (req.method == 'GET' && req.url.path == '/api/v1/print-designs') {
        return http.Response(jsonEncode({'success': true, 'data': sampleDesigns}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (req.method == 'GET' && req.url.path == '/api/v1/nfc-orders') {
        return http.Response(jsonEncode({'success': true, 'data': sampleOrders}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      if (req.method == 'POST' && req.url.path == '/api/v1/nfc-orders') {
        return http.Response(jsonEncode({'success': true, 'data': newOrderResponse}), 200,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    // Chuyển sang Tab 2
    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    // Nhập họ tên
    final nameField = find.widgetWithText(TextFormField, 'Nhập họ tên người nhận thẻ');
    await tester.enterText(nameField, 'Lê Văn An');

    // Nhập SĐT chuẩn Việt Nam
    final phoneField = find.widgetWithText(TextFormField, 'VD: 0901234567 hoặc 0987654321');
    await tester.enterText(phoneField, '0988776655');

    // Nhập địa chỉ
    final addressField = find.widgetWithText(TextFormField, 'Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố');
    await tester.enterText(addressField, '99 Hai Bà Trưng, Quận 1, TP. HCM');

    // Bấm nút đặt hàng
    final submitBtn = find.text('Gửi Đơn Đặt Mua Phôi Thẻ NFC');
    await tester.ensureVisible(submitBtn);
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();

    // Kiểm tra Dialog thành công xuất hiện
    expect(find.text('Đặt hàng thành công!'), findsOneWidget);
    expect(find.textContaining('Thẻ gỗ Walnut sang trọng'), findsWidgets);
    expect(find.textContaining('10 thẻ'), findsWidgets);
    expect(find.textContaining('450.000 đ'), findsWidgets);

    // Bấm Xem lịch sử đơn
    await tester.tap(find.text('Xem lịch sử đơn'));
    await tester.pumpAndSettle();

    // Xác nhận đã chuyển sang Tab 3 Lịch sử đơn hàng và thấy đơn mới
    expect(find.textContaining('Đơn hàng #A1B2C3D4'), findsOneWidget);
    expect(find.text('Lê Văn An (0988776655)'), findsOneWidget);
    expect(find.text('99 Hai Bà Trưng, Quận 1, TP. HCM'), findsOneWidget);
    expect(find.text('Mới tiếp nhận'), findsWidgets);
  });
}
