import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cx_shield/core/models/rate_result_model.dart';
import 'package:cx_shield/core/models/survey_init_model.dart';
import 'package:cx_shield/screens/m1_02_google_review_screen.dart';

void main() {
  const mockSurvey = SurveyInitModel(
    sessionId: '11111111-1111-1111-1111-111111111111',
    qrCode: 'MC-B04',
    businessName: 'Maison Coffee & Bistro',
    branchName: 'Chi nhánh Quận 1 - Đồng Khởi',
    tableOrAreaCode: 'Bàn 04',
    primaryColor: '#2C1810',
    hotline: '02838221122',
  );

  const mockRate5 = RateResultModel(
    responseId: '22222222-2222-2222-2222-222222222222',
    sessionId: '11111111-1111-1111-1111-111111111111',
    starRating: 5,
    sentimentGroup: 'POSITIVE',
    targetScreen: 'M1-02',
    allowUrgentCall: false,
    message: 'Cảm ơn bạn đã hài lòng!',
    hotline: '02838221122',
  );

  testWidgets('M1-02 hiển thị lời cảm ơn 5 sao, câu gợi ý và nút sao chép Clipboard', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedText = (methodCall.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: M102GoogleReviewScreen(surveyData: mockSurvey, rateResult: mockRate5),
      ),
    );

    expect(find.text('Cảm ơn bạn đã chấm 5 sao!'), findsOneWidget);
    expect(find.textContaining('Gợi ý nhận xét (tự động copy)'), findsOneWidget);
    expect(find.text('Đăng Đánh Giá Lên Google Maps'), findsOneWidget);
    expect(find.textContaining('Voucher'), findsNothing);

    await tester.tap(find.text('Sao chép'));
    await tester.pump();

    expect(copiedText, isNotNull);
    expect(copiedText, contains('Maison Coffee & Bistro'));
    expect(find.text('Đã chép'), findsOneWidget);
  });

  testWidgets('M1-02 bấm Đăng Đánh Giá Lên Google Maps tự động copy và mở hộp thoại xác nhận', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: M102GoogleReviewScreen(surveyData: mockSurvey, rateResult: mockRate5),
      ),
    );

    await tester.ensureVisible(find.text('Đăng Đánh Giá Lên Google Maps'));
    await tester.tap(find.text('Đăng Đánh Giá Lên Google Maps'));
    await tester.pumpAndSettle();

    expect(find.text('Mở Google Maps'), findsOneWidget);
    expect(find.text('Đã hiểu & Tiếp tục'), findsOneWidget);
  });
}