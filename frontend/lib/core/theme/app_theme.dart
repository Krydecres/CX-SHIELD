import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  /// Gắn phông chữ cho bộ cỡ chữ. main() đặt phông Be Vietnam Pro; test để trống nên không tải phông qua mạng.
  static TextStyle Function(TextStyle)? fontStyle;

  static TextTheme _withFont(TextTheme base) {
    final apply = fontStyle;
    if (apply == null) return base;
    return base.copyWith(
      headlineSmall: apply(base.headlineSmall!),
      titleLarge: apply(base.titleLarge!),
      titleMedium: apply(base.titleMedium!),
      bodyLarge: apply(base.bodyLarge!),
      bodyMedium: apply(base.bodyMedium!),
      bodySmall: apply(base.bodySmall!),
      labelLarge: apply(base.labelLarge!),
    );
  }

  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.sidebar,
      onSecondary: c.onSidebar,
      secondaryContainer: c.secondarySoft,
      onSecondaryContainer: c.secondary,
      error: c.error,
      onError: isDark ? const Color(0xFF2A0E0E) : Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      outline: c.border,
      outlineVariant: c.border,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: c.border),
    );

    final baseTextTheme = TextTheme(
      headlineSmall: TextStyle(fontSize: 26, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: c.textPrimary),
      titleLarge: TextStyle(fontSize: 20, height: 1.3, fontWeight: FontWeight.w700, color: c.textPrimary),
      titleMedium: TextStyle(fontSize: 16, height: 1.4, fontWeight: FontWeight.w600, color: c.textPrimary),
      bodyLarge: TextStyle(fontSize: 15, height: 1.5, color: c.textPrimary),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: c.textPrimary),
      bodySmall: TextStyle(fontSize: 13, height: 1.45, color: c.textSecondary),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
    final textTheme = _withFont(baseTextTheme);
    const pressDuration = Duration(milliseconds: 140);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      scaffoldBackgroundColor: c.background,
      dividerColor: c.border,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintStyle: TextStyle(color: c.textMuted),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.accent, width: 1.5)),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.error)),
        focusedErrorBorder: inputBorder.copyWith(borderSide: BorderSide(color: c.error, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.border,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelLarge,
          animationDuration: pressDuration,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelLarge,
          animationDuration: pressDuration,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: textTheme.labelLarge,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? c.sidebarHover : c.sidebar,
        contentTextStyle: TextStyle(color: c.onSidebar),
        behavior: SnackBarBehavior.floating,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(color: c.surface),
      drawerTheme: DrawerThemeData(backgroundColor: c.sidebar),
    );
  }
}
