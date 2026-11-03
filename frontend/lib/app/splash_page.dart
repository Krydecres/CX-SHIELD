import 'package:flutter/material.dart';

import '../core/session/session_controller.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/notice_banner.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key, required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            if (session.status != SessionStatus.profileError) {
              return CircularProgressIndicator(color: context.colors.accent);
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NoticeBanner(
                      title: 'Không tải được hồ sơ',
                      message: session.profileError ?? 'Đã có lỗi xảy ra.',
                      type: NoticeType.error,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: session.signOut, child: const Text('Đăng xuất')),
                        const SizedBox(width: 8),
                        FilledButton(onPressed: session.reloadProfile, child: const Text('Thử lại')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
