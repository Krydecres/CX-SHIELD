import 'dart:convert';

import 'package:cx_shield/core/models/rate_result_model.dart';
import 'package:cx_shield/core/models/survey_init_model.dart';
import 'package:cx_shield/core/services/survey_api_service.dart';
import 'package:cx_shield/screens/m1_01_rating_screen.dart';
import 'package:cx_shield/screens/m1_02_google_review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const surveyData = SurveyInitModel(
    sessionId: 'session-123',
    qrCode: 'MC-B04',
    businessName: 'Maison Coffee & Bistro',
    branchName: 'Chi nhánh Quận 1',
    branchAddress: '123 Đồng Khởi, Q1',
    tableOrAreaCode: 'Bàn 04',
    logoUrl: null,
    primaryColor: '#1E3A8A',
    hotline: '02838221122',
  );

  const rateResult5Star = RateResultModel(
    responseId: 'resp-5star-123',
    sessionId: 'session-123',
    starRating: 5,
    sentimentGroup: 'POSITIVE',
    targetScreen: 'M1-02',
    allowUrgentCall: false,
    message: 'Cảm ơn bạn đã chấm 5 sao!',
    hotline: '02838221122',
    suggestedKeywords: [
      'Cà phê đậm đà ngon',
      'Không gian ấm cúng, view đẹp',
      'Nhân viên nhiệt tình, chu đáo',
      'Phục vụ nhanh chóng',
    ],
    publicReviewEnabled: true,
    reviewDirectUrl: 'https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef',
    placeName: 'Maison Coffee & Bistro - Đồng Khởi',
  );

  Widget createTestWidget({
    RateResultModel rateResult = rateResult5Star,
    SurveyApiService? apiService,
  }) {
    return MaterialApp(
      home: M102GoogleReviewScreen(
        surveyData: surveyData,
        rateResult: rateResult,
        apiService: apiService,
      ),
    );
  }

  testWidgets('E1.2: Hiển thị đầy đủ giao diện M1-02, từ khóa gợi ý và câu nhận xét mẫu', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Tiêu đề và lời cảm ơn 5 sao
    expect(find.text('M1-02: Đánh giá Google Maps'), findsOneWidget);
    expect(find.text('Cảm ơn bạn đã chấm 5 sao!'), findsOneWidget);
    expect(find.textContaining('Maison Coffee & Bistro'), findsWidgets);

    // 2. Từ khóa gợi ý SEO từ cấu hình D3-07
    expect(find.text('Chạm chọn từ khóa bạn ấn tượng nhất:'), findsOneWidget);
    expect(find.text('Cà phê đậm đà ngon'), findsOneWidget);
    expect(find.text('Không gian ấm cúng, view đẹp'), findsOneWidget);
    expect(find.text('Nhân viên nhiệt tình, chu đáo'), findsOneWidget);
    expect(find.text('Phục vụ nhanh chóng'), findsOneWidget);

    // 3. Hộp nhận xét gợi ý tự động sinh
    expect(find.text('Gợi ý nhận xét (bấm để sao chép):'), findsOneWidget);
    expect(find.textContaining('Trải nghiệm tại Maison Coffee & Bistro rất tuyệt vời!'), findsOneWidget);
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

    // 4. Nút mở Google Maps & huy hiệu tuân thủ chính sách Google Review
    expect(find.text('Đăng Đánh Giá Lên Google Maps'), findsOneWidget);
    expect(find.textContaining('Tuân thủ chính sách Google'), findsOneWidget);

    // 5. Nút trở lại khảo sát
    expect(find.text('← Trở lại khảo sát'), findsOneWidget);
  });

  testWidgets('E1.2: Tương tác từ khóa SEO và sao chép câu nhận xét vào Clipboard', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    String? clipboardText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          clipboardText = (methodCall.arguments as Map)['text'] as String?;
          return null;
        }
        return null;
      },
    );

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Chọn thêm từ khóa "Phục vụ nhanh chóng"
    final kwChip = find.text('Phục vụ nhanh chóng');
    await tester.ensureVisible(kwChip);
    await tester.tap(kwChip);
    await tester.pumpAndSettle();

    // Bấm nút sao chép
    final copyBtn = find.byTooltip('Sao chép gợi ý');
    await tester.ensureVisible(copyBtn);
    await tester.tap(copyBtn);
    await tester.pumpAndSettle();

    // Kiểm tra thông báo sao chép
    expect(find.text('Đã sao chép câu gợi ý vào bộ nhớ tạm!'), findsOneWidget);
    expect(clipboardText, isNotNull);
    expect(clipboardText, contains('Phục vụ nhanh chóng'));
  });

  testWidgets('E1.2: Bấm nút mở Google Maps gọi API ghi nhận redirect_clicked_at và tự động sao chép', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool redirectApiCalled = false;
    String? clipboardText;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          clipboardText = (methodCall.arguments as Map)['text'] as String?;
          return null;
        }
        return null;
      },
    );

    final mockClient = MockClient((request) async {
      if (request.url.path.contains('/surveys/google-redirect')) {
        redirectApiCalled = true;
        final decodedBody = json.decode(request.body) as Map<String, dynamic>;
        expect(decodedBody['responseId'], 'resp-5star-123');

        return http.Response(
          json.encode({
            'success': true,
            'message': 'Ghi nhận chuyển hướng đánh giá Google Maps thành công',
            'data': {
              'responseId': 'resp-5star-123',
              'redirectClickedAt': DateTime.now().toIso8601String(),
              'reviewPlatformId': 'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
              'platformName': 'Google Maps',
              'reviewDirectUrl': 'https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef',
              'placeName': 'Maison Coffee & Bistro',
            }
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response('Not Found', 404);
    });

    final apiService = SurveyApiService(client: mockClient);

    await tester.pumpWidget(createTestWidget(apiService: apiService));
    await tester.pumpAndSettle();

    // Bấm nút Đăng Đánh Giá Lên Google Maps
    final openGoogleBtn = find.text('Đăng Đánh Giá Lên Google Maps');
    await tester.ensureVisible(openGoogleBtn);
    await tester.tap(openGoogleBtn);
    await tester.pumpAndSettle();

    // Xác nhận API ghi nhận redirect_clicked_at đã được gọi
    expect(redirectApiCalled, isTrue);

    // Xác nhận gợi ý nhận xét đã tự động copy vào clipboard
    expect(clipboardText, isNotNull);
    expect(clipboardText, contains('Maison Coffee & Bistro'));

    // Xác nhận SnackBar thông báo mở Google Maps hiển thị
    expect(find.textContaining('Đang mở trang đánh giá của Maison Coffee & Bistro'), findsOneWidget);
  });

  testWidgets('E1.2: Điều hướng Back an toàn không gây lỗi rỗng stack', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Bấm nút "← Trở lại khảo sát"
    final backBtn = find.text('← Trở lại khảo sát');
    await tester.ensureVisible(backBtn);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Xác nhận điều hướng an toàn về M101RatingScreen
    expect(find.byType(M101RatingScreen), findsOneWidget);
  });
}
