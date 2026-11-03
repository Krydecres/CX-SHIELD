import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum NoticeType { info, success, warning, error }

/// Khối thông báo (nhóm màu 30%); thành công / cảnh báo / lỗi dùng màu ngữ nghĩa.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({super.key, required this.message, this.type = NoticeType.info, this.title, this.action});

  final String message;
  final String? title;
  final NoticeType type;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground, icon) = switch (type) {
      NoticeType.info => (context.colors.secondarySoft, context.colors.secondaryBorder, context.colors.secondary, Icons.info_outline),
      NoticeType.success => (context.colors.successSoft, context.colors.success, context.colors.success, Icons.check_circle_outline),
      NoticeType.warning => (context.colors.warningSoft, context.colors.warning, context.colors.warning, Icons.warning_amber_rounded),
      NoticeType.error => (context.colors.errorSoft, context.colors.error, context.colors.error, Icons.error_outline),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: border, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(title!, style: TextStyle(fontWeight: FontWeight.w600, color: foreground)),
                  ),
                Text(message, style: TextStyle(color: context.colors.textPrimary, height: 1.4)),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}
