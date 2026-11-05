import 'package:cx_shield/core/models/rate_result_model.dart';
import 'package:cx_shield/core/models/survey_init_model.dart';
import 'package:cx_shield/screens/m1_01_rating_screen.dart';
import 'package:cx_shield/screens/m1_02_google_review_screen.dart';
import 'package:cx_shield/screens/m1_04_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleSurveyData = SurveyInitModel(
    sessionId: 'test-session-scrum189',
    qrCode: 'MC-B04',
    businessName: 'Maison Coffee & Bistro',
    branchName: 'Chi nhánh Quận 1 - Đồng Khởi',
    branchAddress: '123 Đồng Khởi, Bến Nghé, Q1, TP. HCM',
    tableOrAreaCode: 'Bàn 04',
    primaryColor: '#2C1810',
    hotline: '02838221122',
  );

  const rateResult1Star = RateResultModel(
    responseId: 'test-response-1star',
    sessionId: 'test-session-scrum189',
    starRating: 1,
    sentimentGroup: 'NEGATIVE',
    targetScreen: 'M1-04',
    allowUrgentCall: true,
    message: 'Rất tiếc vì bạn chưa hài lòng. Hãy để lại góp ý hoặc gọi trực tiếp quản lý để được hỗ trợ ngay tại bàn.',
    hotline: '02838221122',
  );

  const rateResult5Stars = RateResultModel(
    responseId: 'test-response-5stars',
    sessionId: 'test-session-scrum189',
    starRating: 5,
    sentimentGroup: 'POSITIVE',
    targetScreen: 'M1-02',
    allowUrgentCall: false,
    message: 'Cảm ơn bạn đã hài lòng! Hãy chia sẻ trải nghiệm tuyệt vời lên Google Maps.',
    hotline: '02838221122',
  );

  group('SCRUM-189: Bộ kiểm thử Widget bổ sung cho Khảo sát QR', () {
    testWidgets('SCRUM-189 / TC08: Đánh giá 1 sao hiển thị khối cảnh báo khẩn cấp trên M1-04', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: M104FeedbackScreen(
            surveyData: sampleSurveyData,
            rateResult: rateResult1Star,
          ),
        ),
      );

      // Xác nhận hiển thị banner xin lỗi 1 sao
      expect(find.textContaining('Bạn đã đánh giá 1 sao'), findsOneWidget);

      // Xác nhận xuất hiện khối màu vàng cam hỗ trợ khẩn cấp tại bàn (do allowUrgentCall = true)
      expect(find.textContaining('Cần giải quyết nóng tại bàn? Bấm vào đây để gọi Quản lý'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on_rounded), findsOneWidget);
    });

    testWidgets('SCRUM-189 / TC10: Validation nội dung góp ý ngắn dưới 3 ký tự bị chặn', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: M104FeedbackScreen(
            surveyData: sampleSurveyData,
            rateResult: rateResult1Star,
          ),
        ),
      );

      // Nhập nội dung chỉ có 2 ký tự ("Ko")
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Ko');

      final submitBtn = find.text('Gửi Góp Ý Riêng Tới Quản Lý');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Kiểm tra thông báo lỗi validation biên dưới
      expect(find.text('Nội dung góp ý quá ngắn (tối thiểu 3 ký tự)'), findsOneWidget);
    });

    testWidgets('SCRUM-189 / TC14: Xác minh điểm bất thường điều hướng Back trên M1-02 (canPop là false sau pushReplacement)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: M101RatingScreen(qrCode: 'MC-B04'),
        ),
      );

      // 1. Chạm vào ngôi sao 5 sao để kích hoạt chuyển màn
      final starIcons = find.byIcon(Icons.star_outline_rounded);
      await tester.tap(starIcons.at(4));
      await tester.pumpAndSettle();

      // 2. Xác nhận đã vào M1-02
      expect(find.byType(M102GoogleReviewScreen), findsOneWidget);

      // 3. Kiểm tra tính chất ngăn xếp: Sau pushReplacement, Route M1-01 đã bị xóa khỏi Stack
      // Do đó Navigator.canPop() tại M1-02 trả về false
      final m102Context = tester.element(find.byType(M102GoogleReviewScreen));
      expect(Navigator.of(m102Context).canPop(), isFalse,
          reason: 'Điểm bất thường: M1-02 là Route gốc duy nhất trong stack do M1-01 dùng pushReplacement, dẫn đến việc bấm pop() bị lỗi/đứng.');

      // 4. Nút Back in-app vẫn tồn tại trên giao diện M1-02
      final backButton = find.text('← Trở lại khảo sát');
      expect(backButton, findsOneWidget);
    });
  });
}

