import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/theme_controller.dart';

/// Nút chọn giao diện: Sáng / Tối / Theo hệ thống.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  static const _options = [
    (ThemeMode.light, 'Sáng', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Tối', Icons.dark_mode_outlined),
    (ThemeMode.system, 'Theo hệ thống', Icons.brightness_auto_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.of(context);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Giao diện sáng / tối',
      initialValue: controller.mode,
      onSelected: controller.setMode,
      icon: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: colors.textSecondary),
      itemBuilder: (context) => [
        for (final (mode, label, icon) in _options)
          PopupMenuItem(
            value: mode,
            child: Row(
              children: [
                Icon(icon, size: 18, color: mode == controller.mode ? colors.accent : colors.textMuted),
                const SizedBox(width: 10),
                Text(label),
              ],
            ),
          ),
      ],
    );
  }
}
