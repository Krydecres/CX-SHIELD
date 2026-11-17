import 'package:cx_shield/core/services/survey_api_service.dart';
import 'package:cx_shield/screens/m1_01_rating_screen.dart';
import 'package:cx_shield/screens/m1_02_google_review_screen.dart';
import 'package:cx_shield/screens/m1_04_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// SCRUM-255: quay lại M1-01 từ M1-02 / M1-04 rồi chọn sao lần nữa không được treo vòng xoay.
void main() {
  late int rateCalls;
  late SurveyApiService apiService;

  setUp(() {
    rateCalls = 0;
    // Backend trả lỗi để dịch vụ dùng quyết định cục bộ: 4-5 sao -> M1-02, 1-3 sao -> M1-04.
    apiService = SurveyApiService(
      client: MockClient((request) async {
        if (request.method == 'POST' && request.url.path.endsWith('/rate')) rateCalls++;
        return http.Response('{}', 503);
      }),
    );
  });

  Future<void> pumpRatingScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(MaterialApp(home: M101RatingScreen(qrCode: 'MC-B04', apiService: apiService)));
    await tester.pumpAndSettle();
  }

  Future<void> tapStar(WidgetTester tester, int stars) async {
    final star = find.byIcon(Icons.star_outline_rounded).at(stars - 1);
    await tester.ensureVisible(star);
    await tester.tap(star);
    await tester.pumpAndSettle();
  }

  Future<void> tapBackToSurvey(WidgetTester tester) async {
    final back = find.text('← Trở lại khảo sát');
    await tester.ensureVisible(back);
    await tester.tap(back);
    await tester.pumpAndSettle();
  }

  testWidgets('TC-223-05: 4 sao -> M1-02 -> "← Trở lại khảo sát" -> chọn lại 4 sao vào lại M1-02', (tester) async {
    await pumpRatingScreen(tester);

    await tapStar(tester, 4);
    expect(find.byType(M102GoogleReviewScreen), findsOneWidget);

    await tapBackToSurvey(tester);
    expect(find.byType(M102GoogleReviewScreen), findsNothing);
    expect(find.text('Đang chuyển tiếp...'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tapStar(tester, 4);
    expect(find.byType(M102GoogleReviewScreen), findsOneWidget);
    expect(rateCalls, 2);
  });

  testWidgets('Nút mũi tên trên thanh tiêu đề M1-02 cũng mở khóa chọn sao', (tester) async {
    await pumpRatingScreen(tester);

    await tapStar(tester, 5);
    await tester.tap(find.byTooltip('Trở lại khảo sát'));
    await tester.pumpAndSettle();
    expect(find.text('Đang chuyển tiếp...'), findsNothing);

    await tapStar(tester, 5);
    expect(find.byType(M102GoogleReviewScreen), findsOneWidget);
    expect(rateCalls, 2);
  });

  testWidgets('1-3 sao: quay lại từ M1-04 rồi chọn lại vẫn chuyển màn', (tester) async {
    await pumpRatingScreen(tester);

    await tapStar(tester, 2);
    expect(find.byType(M104FeedbackScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Quay lại khảo sát'));
    await tester.pumpAndSettle();
    expect(find.byType(M104FeedbackScreen), findsNothing);
    expect(find.text('Đang chuyển tiếp...'), findsNothing);

    await tapStar(tester, 4);
    expect(find.byType(M102GoogleReviewScreen), findsOneWidget);
    expect(rateCalls, 2);
  });
}
