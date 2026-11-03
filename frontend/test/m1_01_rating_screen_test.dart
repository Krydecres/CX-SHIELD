import 'package:cx_shield/screens/m1_01_rating_screen.dart';
import 'package:cx_shield/screens/m1_02_google_review_screen.dart';
import 'package:cx_shield/screens/m1_04_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('E1.1: M1-01 hiển thị ngay tức thì cơ sở Maison Coffee & Bistro và Bàn 04', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: M101RatingScreen(qrCode: 'MC-B04'),
      ),
    );

    // Kiểm tra hiển thị tên cơ sở và bàn ngay lập tức (<1s không cần chờ đợi)
    expect(find.text('Maison Coffee & Bistro'), findsOneWidget);
    expect(find.textContaining('Bàn 04'), findsOneWidget);
    expect(find.text('Trải nghiệm của bạn hôm nay thế nào?'), findsOneWidget);
    expect(find.text('CX-SHIELD • Review Funnel'), findsOneWidget);

    // Kiểm tra có đủ 5 ngôi sao
    expect(find.byIcon(Icons.star_outline_rounded), findsNWidgets(5));
  });

  testWidgets('E1.1: Chọn 5 sao điều hướng sang M1-02 (Google Maps)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: M101RatingScreen(qrCode: 'MC-B04'),
      ),
    );

    // Nhấn vào ngôi sao thứ 5
    final starIcons = find.byIcon(Icons.star_outline_rounded);
    await tester.tap(starIcons.at(4));
    await tester.pumpAndSettle();

    // Xác nhận đã điều hướng sang màn hình M1-02
    expect(find.byType(M102GoogleReviewScreen), findsOneWidget);
    expect(find.textContaining('Cảm ơn bạn đã chấm 5 sao!'), findsOneWidget);
    expect(find.text('Đăng Đánh Giá Lên Google Maps'), findsOneWidget);
  });

  testWidgets('E1.1: Chọn 2 sao điều hướng sang M1-04 (Góp ý nội bộ)', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: M101RatingScreen(qrCode: 'MC-B04'),
      ),
    );

    // Nhấn vào ngôi sao thứ 2
    final starIcons = find.byIcon(Icons.star_outline_rounded);
    await tester.tap(starIcons.at(1));
    await tester.pumpAndSettle();

    // Xác nhận đã điều hướng sang màn hình M1-04
    expect(find.byType(M104FeedbackScreen), findsOneWidget);
    expect(find.textContaining('Bạn đã đánh giá 2 sao'), findsOneWidget);
    expect(find.text('Gửi Góp Ý Riêng Tới Quản Lý'), findsOneWidget);
  });
}

