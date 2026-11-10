import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/session/session_controller.dart';
import '../features/d3_00_admin_shell/admin_menu.dart';
import '../features/d3_00_admin_shell/admin_shell.dart';
import '../features/d3_00_admin_shell/coming_soon_page.dart';
import '../features/d3_01_auth/auth_page.dart';
import '../features/d3_02_onboarding/onboarding_page.dart';
import '../features/d3_05_google_place/google_place_page.dart';
import '../features/d4_01_alert_channels/alert_channels_page.dart';
import '../features/d5_01_dashboard/dashboard_page.dart';
import '../features/d5_10_billing/billing_models.dart';
import '../features/d5_10_billing/checkout_page.dart';
import '../features/d5_10_billing/payment_result_page.dart';
import '../features/d5_10_billing/pricing_page.dart';
import '../features/d5_10_billing/subscription_page.dart';
import '../screens/m1_01_rating_screen.dart';
import 'splash_page.dart';

const _splash = '/';
const _login = '/login';
const _onboarding = '/onboarding';
const _dashboard = '/dashboard';
const _googlePlace = '/funnel/google-place';
const _alertChannels = '/alerts/channels';
const _billingPlans = '/billing/plans';
const _billingSubscription = '/billing/subscription';
const _billingCheckout = '$_billingPlans/checkout';
const _billingResult = '$_billingPlans/result';

/// Các mục menu đã có màn thật; mục còn lại hiện trang "Sắp ra mắt".
const _builtPages = {_dashboard, _googlePlace, _alertChannels, _billingPlans, _billingSubscription};

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
    // VNPAY chuyển trình duyệt về làm app tải lại: giữ trang kết quả trong lúc khôi phục phiên.
    case SessionStatus.initializing when path == _billingResult:
    case SessionStatus.loadingProfile when path == _billingResult:
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
          GoRoute(path: _alertChannels, builder: (context, state) => AlertChannelsPage(session: session)),
          GoRoute(path: _billingPlans, builder: (context, state) => PricingPage(session: session)),
          GoRoute(path: _billingSubscription, builder: (context, state) => SubscriptionPage(session: session)),
          GoRoute(
            path: _billingCheckout,
            builder: (context, state) => CheckoutPage(
              session: session,
              planId: state.uri.queryParameters['planId'],
              cycle: BillingCycle.fromApi(state.uri.queryParameters['cycle']),
            ),
          ),
          GoRoute(
            path: _billingResult,
            builder: (context, state) =>
                PaymentResultPage(session: session, transactionCode: state.uri.queryParameters['code']),
          ),
          for (final item in adminMenu.where((i) => !_builtPages.contains(i.path)))
            GoRoute(path: item.path, builder: (context, state) => ComingSoonPage(item: item)),
        ],
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(body: Center(child: Text('Không tìm thấy trang.'))),
  );
}
