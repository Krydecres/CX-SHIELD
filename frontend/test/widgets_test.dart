import 'package:cx_shield/core/theme/app_colors.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/core/theme/theme_controller.dart';
import 'package:cx_shield/core/widgets/form_label.dart';
import 'package:cx_shield/core/widgets/notice_banner.dart';
import 'package:cx_shield/core/widgets/theme_mode_button.dart';
import 'package:cx_shield/features/d3_05_google_place/google_place_models.dart';
import 'package:cx_shield/features/d3_05_google_place/google_place_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget wrap(Widget child, {ThemeData? theme}) =>
      MaterialApp(theme: theme ?? AppTheme.light(), home: Scaffold(body: child));

  group('NoticeBanner', () {
    testWidgets('hiện tiêu đề, nội dung và nút hành động', (tester) async {
      await tester.pumpWidget(wrap(NoticeBanner(
        title: 'Đã lưu',
        message: 'Cấu hình đã được lưu.',
        type: NoticeType.success,
        action: TextButton(onPressed: () {}, child: const Text('Xem')),
      )));

      expect(find.text('Đã lưu'), findsOneWidget);
      expect(find.text('Cấu hình đã được lưu.'), findsOneWidget);
      expect(find.text('Xem'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('mỗi loại thông báo có biểu tượng riêng', (tester) async {
      const icons = {
        NoticeType.info: Icons.info_outline,
        NoticeType.warning: Icons.warning_amber_rounded,
        NoticeType.error: Icons.error_outline,
      };
      for (final entry in icons.entries) {
        await tester.pumpWidget(wrap(NoticeBanner(message: 'Nội dung', type: entry.key)));

        expect(find.byIcon(entry.value), findsOneWidget);
      }
    });
  });

  group('FormLabel', () {
    testWidgets('trường bắt buộc có dấu sao', (tester) async {
      await tester.pumpWidget(wrap(const FormLabel('Tên thương hiệu', required: true)));

      expect(find.textContaining('*', findRichText: true), findsOneWidget);
    });

    testWidgets('trường không bắt buộc không có dấu sao', (tester) async {
      await tester.pumpWidget(wrap(const FormLabel('Số điện thoại')));

      expect(find.textContaining('Số điện thoại', findRichText: true), findsOneWidget);
      expect(find.textContaining('*', findRichText: true), findsNothing);
    });
  });

  group('StatusChip', () {
    testWidgets('hiện nhãn trạng thái ở cả hai giao diện', (tester) async {
      await tester.pumpWidget(wrap(const StatusChip(status: PlaceConnectionStatus.connected)));
      expect(find.text('Đã kết nối'), findsOneWidget);

      await tester.pumpWidget(wrap(const StatusChip(status: PlaceConnectionStatus.error), theme: AppTheme.dark()));
      expect(find.text('Lỗi Place ID'), findsOneWidget);
    });
  });

  group('ThemeModeButton', () {
    late ThemeController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      controller = await ThemeController.load();
    });

    Widget app() => ThemeScope(
          controller: controller,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => MaterialApp(
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: controller.mode,
              home: const Scaffold(body: ThemeModeButton()),
            ),
          ),
        );

    testWidgets('hiện đủ 3 lựa chọn', (tester) async {
      await tester.pumpWidget(app());

      await tester.tap(find.byType(ThemeModeButton));
      await tester.pumpAndSettle();

      expect(find.text('Sáng'), findsOneWidget);
      expect(find.text('Tối'), findsOneWidget);
      expect(find.text('Theo hệ thống'), findsOneWidget);
    });

    testWidgets('chọn Tối đổi giao diện và biểu tượng', (tester) async {
      await tester.pumpWidget(app());
      expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);

      await tester.tap(find.byType(ThemeModeButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tối'));
      await tester.pumpAndSettle();

      expect(controller.mode, ThemeMode.dark);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      final context = tester.element(find.byType(ThemeModeButton));
      expect(context.colors, AppColors.dark);
    });
  });

  group('ThemeController', () {
    test('giá trị đã lưu không hợp lệ quay về giao diện sáng', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'khong-hop-le'});

      expect((await ThemeController.load()).mode, ThemeMode.light);
    });

    test('chọn lại giao diện đang dùng không báo cập nhật', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final controller = await ThemeController.load();
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.setMode(ThemeMode.dark);
      await controller.setMode(ThemeMode.system);

      expect(notified, 1);
      expect((await ThemeController.load()).mode, ThemeMode.system);
    });
  });

  group('AppColors', () {
    test('chuyển dần giữa hai bảng màu', () {
      final middle = AppColors.light.lerp(AppColors.dark, 0.5);

      expect(AppColors.light.lerp(AppColors.dark, 0).background, AppColors.light.background);
      expect(AppColors.light.lerp(AppColors.dark, 1).background, AppColors.dark.background);
      expect(middle.background, isNot(AppColors.light.background));
      expect(AppColors.light.lerp(null, 0.5), AppColors.light);
    });

    test('nhãn trên nút accent đạt tương phản 4.5:1 ở cả hai giao diện', () {
      double contrast(Color a, Color b) {
        final (x, y) = (a.computeLuminance(), b.computeLuminance());
        return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
      }

      expect(contrast(AppColors.light.accent, AppColors.light.onAccent), greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.dark.accent, AppColors.dark.onAccent), greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.light.textMuted, AppColors.light.surface), greaterThanOrEqualTo(4.5));
      expect(contrast(AppColors.dark.textMuted, AppColors.dark.surface), greaterThanOrEqualTo(4.5));
      expect(AppColors.dark.background, isNot(AppColors.light.background));
    });
  });
}
