import 'package:flutter/material.dart';

/// Bảng màu theo quy tắc 60-30-10, có bản sáng và bản tối.
///
/// * 60% – nền trung tính: nền trang, thẻ, ô nhập.
/// * 30% – xanh slate: menu bên, thông báo, khung thông tin, nhãn trạng thái.
/// * 10% – cam nhấn: nút hành động chính, mục menu đang chọn, liên kết.
///
/// Lấy màu theo theme hiện tại bằng `context.colors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.sidebar,
    required this.sidebarHover,
    required this.onSidebar,
    required this.onSidebarMuted,
    required this.secondary,
    required this.secondarySoft,
    required this.secondaryBorder,
    required this.accent,
    required this.accentHover,
    required this.accentSoft,
    required this.onAccent,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.error,
    required this.errorSoft,
  });

  static const light = AppColors(
    // 60 – nền
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE3E6EB),
    textPrimary: Color(0xFF1B2333),
    textSecondary: Color(0xFF5B6475),
    textMuted: Color(0xFF8A93A3),
    // 30 – menu bên, thông báo, khung phụ
    sidebar: Color(0xFF23395B),
    sidebarHover: Color(0xFF2E4A73),
    onSidebar: Color(0xFFFFFFFF),
    onSidebarMuted: Color(0xFFB4C2D6),
    secondary: Color(0xFF23395B),
    secondarySoft: Color(0xFFE8EEF6),
    secondaryBorder: Color(0xFFC8D5E6),
    // 10 – chức năng chính
    accent: Color(0xFFF26B21),
    accentHover: Color(0xFFD95A14),
    accentSoft: Color(0xFFFDEDE3),
    onAccent: Color(0xFFFFFFFF),
    // Màu ngữ nghĩa cho trạng thái
    success: Color(0xFF1E8E5A),
    successSoft: Color(0xFFE3F4EC),
    warning: Color(0xFFB7791F),
    warningSoft: Color(0xFFFBF1DE),
    error: Color(0xFFD64545),
    errorSoft: Color(0xFFFCE8E8),
  );

  static const dark = AppColors(
    background: Color(0xFF0F141C),
    surface: Color(0xFF171D28),
    border: Color(0xFF2A3241),
    textPrimary: Color(0xFFE7EAF0),
    textSecondary: Color(0xFFA6AEBC),
    textMuted: Color(0xFF768091),
    sidebar: Color(0xFF16233A),
    sidebarHover: Color(0xFF22344F),
    onSidebar: Color(0xFFF1F4F9),
    onSidebarMuted: Color(0xFF9DB0CB),
    secondary: Color(0xFFA9C2E6),
    secondarySoft: Color(0xFF17243A),
    secondaryBorder: Color(0xFF2D4263),
    accent: Color(0xFFF26B21),
    accentHover: Color(0xFFFF8040),
    accentSoft: Color(0xFF3A2416),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF45C38A),
    successSoft: Color(0xFF132B20),
    warning: Color(0xFFE3AC4E),
    warningSoft: Color(0xFF2F2513),
    error: Color(0xFFF07A7A),
    errorSoft: Color(0xFF341B1D),
  );

  final Color background;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Nền menu bên và chữ trên nền đó.
  final Color sidebar;
  final Color sidebarHover;
  final Color onSidebar;
  final Color onSidebarMuted;

  /// Chữ / biểu tượng slate trên khung thông báo, khung thông tin.
  final Color secondary;
  final Color secondarySoft;
  final Color secondaryBorder;

  final Color accent;
  final Color accentHover;
  final Color accentSoft;
  final Color onAccent;

  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color error;
  final Color errorSoft;

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      border: l(border, other.border),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      sidebar: l(sidebar, other.sidebar),
      sidebarHover: l(sidebarHover, other.sidebarHover),
      onSidebar: l(onSidebar, other.onSidebar),
      onSidebarMuted: l(onSidebarMuted, other.onSidebarMuted),
      secondary: l(secondary, other.secondary),
      secondarySoft: l(secondarySoft, other.secondarySoft),
      secondaryBorder: l(secondaryBorder, other.secondaryBorder),
      accent: l(accent, other.accent),
      accentHover: l(accentHover, other.accentHover),
      accentSoft: l(accentSoft, other.accentSoft),
      onAccent: l(onAccent, other.onAccent),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      warning: l(warning, other.warning),
      warningSoft: l(warningSoft, other.warningSoft),
      error: l(error, other.error),
      errorSoft: l(errorSoft, other.errorSoft),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
