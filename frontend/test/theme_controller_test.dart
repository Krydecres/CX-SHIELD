import 'package:cx_shield/core/theme/app_colors.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('mặc định giao diện sáng, lưu lựa chọn tối cho lần mở sau', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = await ThemeController.load();
    expect(controller.mode, ThemeMode.light);

    await controller.setMode(ThemeMode.dark);
    expect((await ThemeController.load()).mode, ThemeMode.dark);
  });

  test('theme sáng và tối đều mang bảng màu 60-30-10', () {
    expect(AppTheme.light().extension<AppColors>(), AppColors.light);
    expect(AppTheme.dark().extension<AppColors>(), AppColors.dark);
    expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
    expect(AppTheme.dark().colorScheme.primary, AppColors.dark.accent);
  });
}
