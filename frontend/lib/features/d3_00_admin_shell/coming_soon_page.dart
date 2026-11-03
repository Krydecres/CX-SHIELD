import 'package:flutter/material.dart';

import '../../core/widgets/notice_banner.dart';
import 'admin_menu.dart';

/// Trang tạm cho các mục menu chưa được phát triển.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.item});

  final AdminMenuItem item;

  @override
  Widget build(BuildContext context) {
    final code = item.screenCode == null ? '' : ' (${item.screenCode})';
    return Padding(
      padding: const EdgeInsets.all(35),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: NoticeBanner(
          title: item.label,
          message: 'Màn hình$code đang được phát triển và sẽ sớm có mặt.',
        ),
      ),
    );
  }
}
