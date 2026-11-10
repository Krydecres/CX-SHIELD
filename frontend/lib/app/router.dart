import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/session/session_controller.dart';
import '../features/d3_00_admin_shell/admin_menu.dart';
import '../features/d3_00_admin_shell/admin_shell.dart';
import '../features/d3_00_admin_shell/coming_soon_page.dart';
import '../features/d3_01_auth/auth_page.dart';
import '../features/d3_02_onboarding/onboarding_page.dart';
import '../features/d3_05_google_place/google_place_page.dart';
import '../features/d3_09_qr_studio/d3_09_qr_studio_page.dart';
import '../features/d3_11_print_nfc/d3_11_print_nfc_page.dart';
import '../features/d5_01_dashboard/dashboard_page.dart';
import '../screens/m1_01_rating_screen.dart';
import 'splash_page.dart';

const _splash = '/';
const _login = '/login';
const _onboarding = '/onboarding';
const _dashboard = '/dashboard';
const _googlePlace = '/funnel/google-place';
const _printMaterials = '/print-materials';

/// Điều hướng theo trạng thái phiên:
/// chưa đăng nhập → D3-01; đăng nhập nhưng chưa có cơ sở → D3-02; đã có cơ sở → khung admin (mặc định D5-01).
String? sessionRedirect(SessionStatus status, bool onboarded, Uri uri, {bool hasProfile = false}) {
  final path = uri.path;

  // Luồng khách hàng quét mã QR (E1.1 - không cần đăng nhập)
  if (path == '/survey' || path.startsWith('/s/')) {
    return null;
  }

  switch (status) {
    case SessionStatus.loadingProfile when hasProfile:
      // Đang làm mới hồ sơ đã có (ví dụ sau khi onboarding): giữ nguyên trang hiện tại.
      return null;
    case SessionStatus.initializing:
    case SessionStatus.loadingProfile:
    case SessionStatus.profileError:
      return path == _splash ? null : _splash;
    case SessionStatus.signedOut:
      return path == _login ? null : _login;
    case SessionStatus.ready:
      if (!onboarded) return path == _onboarding ? null : _onboarding;
      // Vừa hoàn tất bước 1 onboarding → bước 2 là D3-05.
      if (path == _onboarding) return '$_googlePlace?step=onboarding';
      if (path == _splash || path == _login) return _dashboard;
      return null;
  }
}

GoRouter createRouter(SessionController session) {
  return GoRouter(
    initialLocation: _splash,
    refreshListenable: session,
    redirect: (context, state) =>
        sessionRedirect(session.status, session.isOnboarded, state.uri, hasProfile: session.me != null),
    routes: [
      GoRoute(
        path: '/survey',
        builder: (context, state) {
          final qr = state.uri.queryParameters['qr'] ?? 'MC-B04';
          return M101RatingScreen(qrCode: qr);
        },
      ),
      GoRoute(
        path: '/s/:code',
        builder: (context, state) {
          final qr = state.pathParameters['code'] ?? 'MC-B04';
          return M101RatingScreen(qrCode: qr);
        },
      ),
      GoRoute(path: _splash, builder: (context, state) => SplashPage(session: session)),
      GoRoute(path: _login, builder: (context, state) => const AuthPage()),
      GoRoute(path: _onboarding, builder: (context, state) => OnboardingPage(session: session)),
      ShellRoute(
        builder: (context, state, child) => AdminShell(session: session, location: state.uri.path, child: child),
        routes: [
          GoRoute(path: _dashboard, builder: (context, state) => DashboardPage(session: session)),
          GoRoute(
            path: _googlePlace,
            builder: (context, state) => GooglePlacePage(
              session: session,
              isOnboardingStep: state.uri.queryParameters['step'] == 'onboarding',
            ),
          ),
          GoRoute(
            path: _printMaterials,
            builder: (context, state) {
              if (state.uri.queryParameters['view'] == 'export' || state.uri.queryParameters['tab'] == 'export') {
                return D311PrintNfcPage(session: session);
              }
              return D309QrStudioPage(session: session);
            },
          ),
          GoRoute(path: '/print-nfc', builder: (context, state) => D311PrintNfcPage(session: session)),
          for (final item in adminMenu.where((i) => i.path != _dashboard && i.path != _googlePlace && i.path != _printMaterials))
            GoRoute(path: item.path, builder: (context, state) => ComingSoonPage(item: item)),
        ],
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(body: Center(child: Text('Không tìm thấy trang.'))),
  );
}
