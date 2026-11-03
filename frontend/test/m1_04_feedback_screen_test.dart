import 'package:cx_shield/core/models/rate_result_model.dart';
import 'package:cx_shield/core/models/survey_init_model.dart';
import 'package:cx_shield/screens/m1_04_feedback_screen.dart';
import 'package:cx_shield/screens/m1_06_thank_you_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const surveyData = SurveyInitModel(
    sessionId: 'test-session-123',
    qrCode: 'MC-B04',
    businessName: 'Maison Coffee & Bistro',
    branchName: 'Chi nhánh Quận 1 - Đồng Khởi',
    branchAddress: '123 Đồng Khởi, Q1',
    tableOrAreaCode: 'Bàn 04',
    primaryColor: '#2C1810',
    hotline: '02838221122',
  );

  const rateResult2Stars = RateResultModel(
    responseId: 'test-response-123',
    sessionId: 'test-session-123',
    starRating: 2,
    sentimentGroup: 'NEGATIVE',
    targetScreen: 'M1-04',
    allowUrgentCall: false,
    message: 'Rất tiếc vì bạn chưa hài lòng',
    hotline: '02838221122',
  );

  testWidgets('E1.3: M1-04 hiển thị đầy đủ form góp ý, chủ đề, SĐT, checkbox consent và link Google', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: M104FeedbackScreen(
          surveyData: surveyData,
          rateResult: rateResult2Stars,
        ),
      ),
    );

    expect(find.text('M1-04: Góp ý riêng cho cơ sở'), findsOneWidget);
    expect(find.textContaining('Bạn đã đánh giá 2 sao'), findsOneWidget);
    expect(find.text('Món ăn / Đồ uống'), findsOneWidget);
    expect(find.text('Thái độ phục vụ'), findsOneWidget);
    expect(find.textContaining('Tôi đồng ý cho cơ sở liên hệ'), findsOneWidget);
    expect(find.text('Gửi Góp Ý Riêng Tới Quản Lý'), findsOneWidget);
    expect(find.text('Đăng đánh giá công khai lên Google'), findsOneWidget);
  });

  testWidgets('E1.4: Lối đi đánh giá công khai không bắt điền form trước và luôn sẵn sàng bấm', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: M104FeedbackScreen(
          surveyData: surveyData,
          rateResult: rateResult2Stars,
        ),
      ),
    );

    // Không cần điền bất kỳ thông tin nào trong form
    final publicReviewLink = find.text('Đăng đánh giá công khai lên Google');
    expect(publicReviewLink, findsOneWidget);

    await tester.ensureVisible(publicReviewLink);
    await tester.tap(publicReviewLink);
    await tester.pumpAndSettle();

    // Xác nhận hiển thị thông báo chuyển tiếp Google Maps của cơ sở
    expect(find.textContaining('Đang mở trang đánh giá chính thức của Maison Coffee & Bistro'), findsOneWidget);
  });

  testWidgets('E1.3: Kiểm tra dữ liệu - Bắt buộc nhập nội dung góp ý khi bấm Gửi góp ý riêng', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: M104FeedbackScreen(
          surveyData: surveyData,
          rateResult: rateResult2Stars,
        ),
      ),
    );

    // Bấm nút gửi ngay mà chưa nhập nội dung
    final submitButton = find.text('Gửi Góp Ý Riêng Tới Quản Lý');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Vui lòng nhập nội dung góp ý để cơ sở cải thiện'), findsOneWidget);
  });

  testWidgets('E1.3: Kiểm tra dữ liệu - SĐT sai định dạng Việt Nam báo lỗi', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: M104FeedbackScreen(
          surveyData: surveyData,
          rateResult: rateResult2Stars,
        ),
      ),
    );

    // Nhập nội dung hợp lệ
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Món ăn lên hơi chậm.');

    // Nhập SĐT sai định dạng
    await tester.enterText(textFields.at(1), '012345');

    final submitButton = find.text('Gửi Góp Ý Riêng Tới Quản Lý');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Số điện thoại không đúng định dạng VN (ví dụ: 0901234567)'), findsOneWidget);
  });

  testWidgets('E1.3: Gửi góp ý thành công -> chuyển sang màn cảm ơn M1-06', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: M104FeedbackScreen(
          surveyData: surveyData,
          rateResult: rateResult2Stars,
        ),
      ),
    );

    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'Nhân viên phục vụ nước uống hơi lâu, cần khắc phục.');
    await tester.enterText(textFields.at(1), '0901234567');

    final submitButton = find.text('Gửi Góp Ý Riêng Tới Quản Lý');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Xác nhận đã chuyển sang màn hình cảm ơn M1-06
    expect(find.byType(M106ThankYouScreen), findsOneWidget);
    expect(find.text('Cảm ơn bạn đã góp ý!'), findsOneWidget);
    expect(find.text('Nhận Ưu Đãi Tri Ân (M2-01)'), findsOneWidget);
  });
}
