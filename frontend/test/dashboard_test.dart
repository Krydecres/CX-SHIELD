import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d5_01_dashboard/dashboard_api.dart';
import 'package:cx_shield/features/d5_01_dashboard/dashboard_models.dart';
import 'package:cx_shield/features/d5_01_dashboard/dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const json = {
    'scanCount': 1248,
    'ratedCount': 1000,
    'satisfactionRate': 82.5,
    'googleRedirectCount': 684,
    'googleReviewCount': 1032,
    'googleAvgRating': 4.6,
    'weekly': [
      {
        'weekStart': '2026-10-26',
        'scanCount': 100,
        'satisfactionRate': 80,
        'googleRedirectCount': 50,
        'googleReviewCount': 1000,
        'googleAvgRating': 4.5,
      },
      {'weekStart': '2026-11-02', 'scanCount': 50, 'googleRedirectCount': 0},
    ],
  };

  group('đọc dữ liệu API', () {
    test('đủ số liệu', () {
      final data = DashboardData.fromJson(json);

      expect(data.scanCount, 1248);
      expect(data.satisfactionRate, 82.5);
      expect(data.googleAvgRating, 4.6);
      expect(data.weekly, hasLength(2));
      expect(data.weekly.first.satisfactionRate, 80);
      expect(data.weekly.last.googleReviewCount, isNull);
      expect(data.isEmpty, isFalse);
    });

    test('chưa có dữ liệu', () {
      final data = DashboardData.fromJson({'scanCount': 0, 'weekly': []});

      expect(data.isEmpty, isTrue);
      expect(data.satisfactionRate, isNull);
    });
  });

  group('định dạng', () {
    test('số có dấu chấm hàng nghìn', () {
      expect(formatCount(0), '0');
      expect(formatCount(999), '999');
      expect(formatCount(1248), '1.248');
      expect(formatCount(1234567), '1.234.567');
    });

    test('phần trăm và điểm sao', () {
      expect(formatPercent(82.5), '82,5%');
      expect(formatPercent(80), '80%');
      expect(formatPercent(null), '—');
      expect(formatRating(4.6), '4,6★');
      expect(formatRating(null), '—');
    });

    test('ngày', () {
      expect(apiDate(DateTime(2026, 11, 6)), '2026-11-06');
      expect(formatWeek(DateTime(2026, 11, 2)), '02/11');
    });

    test('khoảng thời gian có sẵn', () {
      expect(DashboardRange.weeks8.days, 56);
      expect(DashboardRange.weeks4.label, '4 tuần gần nhất');
    });
  });

  group('gọi API', () {
    late Uri captured;

    DashboardApi api() => DashboardApi(ApiClient(
          baseUrl: 'http://api',
          accessToken: () => 'token',
          httpClient: MockClient((request) async {
            captured = request.url;
            return http.Response('{"scanCount":0}', 200);
          }),
        ));

    test('lọc theo chi nhánh và thời gian', () async {
      await api().load('biz', branchId: 'b1', from: DateTime(2026, 11, 1), to: DateTime(2026, 11, 6));

      expect(captured.path, '/api/v1/businesses/biz/dashboard');
      expect(captured.queryParameters, {'branchId': 'b1', 'from': '2026-11-01', 'to': '2026-11-06'});
    });

    test('tất cả chi nhánh không gửi branchId', () async {
      await api().load('biz', from: DateTime(2026, 11, 1), to: DateTime(2026, 11, 6));

      expect(captured.queryParameters.containsKey('branchId'), isFalse);
    });
  });

  group('widget', () {
    Widget wrap(Widget child) => MaterialApp(theme: AppTheme.light(), home: Scaffold(body: child));

    testWidgets('thẻ số liệu hiện nhãn, giá trị và ghi chú', (tester) async {
      await tester.pumpWidget(wrap(const MetricCard(label: 'Lượt quét QR', value: '1.248', note: 'Ghi chú')));

      expect(find.text('Lượt quét QR'), findsOneWidget);
      expect(find.text('1.248'), findsOneWidget);
      expect(find.text('Ghi chú'), findsOneWidget);
    });

    testWidgets('cột biểu đồ theo tỷ lệ lượt quét', (tester) async {
      final weeks = DashboardData.fromJson(json).weekly;
      await tester.pumpWidget(wrap(WeeklyBarChart(weeks: weeks)));

      final high = tester.getSize(find.byKey(const ValueKey('bar-2026-10-26'))).height;
      final low = tester.getSize(find.byKey(const ValueKey('bar-2026-11-02'))).height;
      expect(high, 150);
      expect(low, 75);
      expect(find.text('26/10'), findsOneWidget);
    });

    testWidgets('biểu đồ không lỗi khi mọi tuần bằng 0', (tester) async {
      await tester.pumpWidget(wrap(WeeklyBarChart(weeks: [
        DashboardWeek(weekStart: DateTime(2026, 11, 2), scanCount: 0, googleRedirectCount: 0),
      ])));

      expect(tester.getSize(find.byKey(const ValueKey('bar-2026-11-02'))).height, 2);
    });

    testWidgets('bảng hiện tuần mới nhất trước và dấu gạch khi thiếu số liệu', (tester) async {
      await tester.pumpWidget(wrap(WeeklyTable(weeks: DashboardData.fromJson(json).weekly)));

      final firstRowY = tester.getTopLeft(find.text('02/11')).dy;
      final secondRowY = tester.getTopLeft(find.text('26/10')).dy;
      expect(firstRowY, lessThan(secondRowY));
      expect(find.text('—'), findsNWidgets(3));
    });
  });
}
