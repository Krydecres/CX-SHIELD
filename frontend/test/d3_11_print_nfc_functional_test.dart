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
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class FakeAuth extends Fake implements GoTrueClient {
  final events = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => events.stream;

  @override
  User? get currentUser => null;
}

class MockUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
  String? launchedUrl;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }
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
  late MockUrlLauncher urlLauncher;

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
    urlLauncher = MockUrlLauncher();
    UrlLauncherPlatform.instance = urlLauncher;
  });

  testWidgets('TC-238-01: Mở màn hình D3-11, hiển thị đầy đủ 3 Tab và Live Preview bản in mặc định', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    expect(find.text('D3-11 • Ấn phẩm QR / NFC'), findsOneWidget);
    expect(find.text('Chuẩn in ấn ≥ 300 DPI'), findsOneWidget);
    expect(find.text('Xuất file in ấn (PDF / PNG)'), findsOneWidget);
    expect(find.text('Đặt phôi thẻ NFC vật lý'), findsOneWidget);
    expect(find.textContaining('Lịch sử đơn hàng'), findsOneWidget);
    expect(find.text('Maison Coffee & Bistro'), findsWidgets);
    expect(find.text('MÃ: MC-B04'), findsOneWidget);
  });

  testWidgets('TC-238-02: Chọn định dạng PNG và bấm tải file in ấn kích hoạt thông báo tải chuẩn 300 DPI', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    // Chọn định dạng PNG trong SegmentedButton
    final pngSegment = find.text('PNG 300 DPI');
    await tester.ensureVisible(pngSegment);
    await tester.tap(pngSegment);
    await tester.pumpAndSettle();

    // Bấm Tải File In Ấn
    final downloadButton = find.textContaining('Tải File In Ấn');
    await tester.ensureVisible(downloadButton);
    await tester.tap(downloadButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Đang tải file ấn phẩm chuẩn in ấn (300 DPI, định dạng PNG)'), findsOneWidget);
    expect(urlLauncher.launchedUrl, contains('format=png'));
    expect(urlLauncher.launchedUrl, contains('dpi=300'));
  });

  testWidgets('TC-238-04: Chọn định dạng PDF và bấm tải file in ấn kích hoạt thông báo tải chuẩn 300 DPI', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    // Chọn định dạng PDF Vector trong SegmentedButton
    final pdfSegment = find.text('PDF Vector');
    await tester.ensureVisible(pdfSegment);
    await tester.tap(pdfSegment);
    await tester.pumpAndSettle();

    // Bấm Tải File In Ấn
    final downloadButton = find.textContaining('Tải File In Ấn');
    await tester.ensureVisible(downloadButton);
    await tester.tap(downloadButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Đang tải file ấn phẩm chuẩn in ấn (300 DPI, định dạng PDF)'), findsOneWidget);
    expect(urlLauncher.launchedUrl, contains('format=pdf'));
    expect(urlLauncher.launchedUrl, contains('dpi=300'));
  });

  testWidgets('TC-238-06: Chọn loại thẻ Gỗ Walnut và Thẻ Mica Acrylic cập nhật đơn giá và tạm tính', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    // Mặc định 10 thẻ Gỗ = 450.000 đ
    expect(find.text('Thẻ Gỗ Walnut sang trọng'), findsOneWidget);
    expect(find.text('Tạm tính: 450.000 đ'), findsOneWidget);

    // Chuyển sang Thẻ Mica Acrylic (35.000 đ/thẻ)
    await tester.tap(find.text('Thẻ Mica Acrylic trong suốt'));
    await tester.pumpAndSettle();
    expect(find.text('Tạm tính: 350.000 đ'), findsOneWidget);
  });

  testWidgets('TC-238-07: Điều chỉnh tăng/giảm số lượng phôi thẻ tính đúng tổng tiền', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    // Tăng số lượng lên 12 thẻ Gỗ (12 * 45.000 = 540.000 đ)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('12'), findsOneWidget);
    expect(find.text('Tạm tính: 540.000 đ'), findsOneWidget);

    // Giảm số lượng xuống 11 thẻ (11 * 45.000 = 495.000 đ)
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(find.text('11'), findsOneWidget);
    expect(find.text('Tạm tính: 495.000 đ'), findsOneWidget);
  });

  testWidgets('TC-238-08: Validation form đặt thẻ NFC chặn gửi đơn khi để trống họ tên, SĐT và địa chỉ', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    final submitButton = find.text('Gửi Đơn Đặt Mua Phôi Thẻ NFC');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập họ và tên người nhận'), findsOneWidget);
    expect(find.text('Vui lòng nhập số điện thoại nhận hàng'), findsOneWidget);
    expect(find.text('Vui lòng nhập địa chỉ giao hàng chi tiết (tối thiểu 5 ký tự)'), findsOneWidget);
  });

  testWidgets('TC-238-09: Validation số điện thoại giao hàng từ chối số sai định dạng Việt Nam', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    final phoneField = find.widgetWithText(TextFormField, 'VD: 0901234567 hoặc 0987654321');
    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '012345678'); // Sai đầu số / thiếu số

    final submitButton = find.text('Gửi Đơn Đặt Mua Phôi Thẻ NFC');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Số điện thoại không đúng định dạng Việt Nam'), findsOneWidget);
  });

  testWidgets('TC-238-10: Validation địa chỉ giao hàng từ chối địa chỉ dưới 5 ký tự', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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

    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    final addressField = find.widgetWithText(TextFormField, 'Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố');
    await tester.ensureVisible(addressField);
    await tester.enterText(addressField, '123 ');

    final submitButton = find.text('Gửi Đơn Đặt Mua Phôi Thẻ NFC');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập địa chỉ giao hàng chi tiết (tối thiểu 5 ký tự)'), findsOneWidget);
  });

  testWidgets('TC-238-11: Gửi đơn đặt phôi thẻ NFC hợp lệ thành công và hiển thị AlertDialog xác nhận', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
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
      'shipName': 'Nguyễn Văn Chủ Mới',
      'shipPhone': '0909999888',
      'shipAddress': '999 Lê Duẩn, Bến Nghé, Quận 1, TP. HCM',
      'status': 'PENDING',
      'statusLabel': 'Mới tiếp nhận',
      'estimatedDelivery': '2-3 ngày làm việc',
      'createdAt': '2026-11-17T12:00:00Z',
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
        return http.Response(jsonEncode({'success': true, 'data': newOrderResponse}), 201,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    // Điền thông tin hợp lệ
    final nameField = find.widgetWithText(TextFormField, 'Nhập họ tên người nhận thẻ');
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'Nguyễn Văn Chủ Mới');

    final phoneField = find.widgetWithText(TextFormField, 'VD: 0901234567 hoặc 0987654321');
    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '0909999888');

    final addressField = find.widgetWithText(TextFormField, 'Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố');
    await tester.ensureVisible(addressField);
    await tester.enterText(addressField, '999 Lê Duẩn, Bến Nghé, Quận 1, TP. HCM');

    // Bấm nút gửi đơn
    final submitButton = find.text('Gửi Đơn Đặt Mua Phôi Thẻ NFC');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Kiểm tra Dialog xác nhận thành công
    expect(find.text('Đặt hàng thành công!'), findsOneWidget);
    expect(find.textContaining('Mã đơn hàng: a1b2c3d4'), findsOneWidget);
    expect(find.text('Tổng tiền: 450.000 đ'), findsOneWidget);

    // Bấm nút Xem lịch sử đơn
    await tester.tap(find.text('Xem lịch sử đơn'));
    await tester.pumpAndSettle();

    // Kiểm tra chuyển sang Tab 3 Lịch sử đơn
    expect(find.textContaining('Lịch sử đơn hàng'), findsWidgets);
    expect(find.textContaining('Nguyễn Văn Chủ Mới'), findsOneWidget);
    expect(find.text('Mới tiếp nhận'), findsWidgets);
  });

  testWidgets('TC-238-12: Xử lý lỗi khi API gửi đơn đặt thẻ NFC thất bại hiển thị SnackBar lỗi', (tester) async {
    tester.view.physicalSize = const Size(1280, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

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
        return http.Response(jsonEncode({'success': false, 'message': 'Lỗi máy chủ kết nối kho'}), 500,
            headers: {'content-type': 'application/json; charset=utf-8'});
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(createTestWidget(client: client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Đặt phôi thẻ NFC vật lý'));
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'Nhập họ tên người nhận thẻ');
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'Nguyễn Văn Chủ');

    final phoneField = find.widgetWithText(TextFormField, 'VD: 0901234567 hoặc 0987654321');
    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '0901234567');

    final addressField = find.widgetWithText(TextFormField, 'Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố');
    await tester.ensureVisible(addressField);
    await tester.enterText(addressField, '123 Đồng Khởi, Quận 1');

    final submitButton = find.text('Gửi Đơn Đặt Mua Phôi Thẻ NFC');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Lỗi khi gửi đơn hàng'), findsOneWidget);
  });
}
