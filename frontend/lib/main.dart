import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'core/api/api_client.dart';
import 'core/config/app_config.dart';
import 'core/session/session_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'screens/m1_01_rating_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Kiểm tra luồng khảo sát QR của khách hàng (E1.1 - không cần đăng nhập hay cấu hình Supabase)
  String qrCode = 'MC-B04';
  bool hasQrParam = false;
  try {
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('qr')) {
      qrCode = uri.queryParameters['qr']!;
      hasQrParam = true;
    } else if (uri.queryParameters.containsKey('code')) {
      qrCode = uri.queryParameters['code']!;
      hasQrParam = true;
    } else if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 's') {
      qrCode = uri.pathSegments[1];
      hasQrParam = true;
    }
  } catch (_) {}

  // Nếu không có cấu hình Supabase (hoặc có param QR), chạy thẳng luồng khảo sát khách hàng M1
  if (!AppConfig.isConfigured || hasQrParam) {
    if (!AppConfig.isConfigured && !hasQrParam) {
      // Khi dev test cục bộ không truyền config, mặc định mở giao diện khảo sát M1-01
      runApp(SurveyStandaloneApp(qrCode: qrCode));
      return;
    }
    if (hasQrParam) {
      runApp(SurveyStandaloneApp(qrCode: qrCode));
      return;
    }
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );
  final theme = await ThemeController.load();
  runApp(CxShieldApp(session: SessionController(api: ApiClient()), theme: theme));
}

/// Ứng dụng độc lập dành cho khách hàng quét mã QR (E1.1: hiển thị tức thì <1s, không cần login)
class SurveyStandaloneApp extends StatelessWidget {
  final String qrCode;

  const SurveyStandaloneApp({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maison Coffee & Bistro - Khảo sát',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1810),
          primary: const Color(0xFF2C1810),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: M101RatingScreen(qrCode: qrCode),
    );
  }
}

class CxShieldApp extends StatefulWidget {
  const CxShieldApp({super.key, required this.session, required this.theme});

  final SessionController session;
  final ThemeController theme;

  @override
  State<CxShieldApp> createState() => _CxShieldAppState();
}

class _CxShieldAppState extends State<CxShieldApp> {
  late final _router = createRouter(widget.session);

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: widget.theme,
      child: ListenableBuilder(
        listenable: widget.theme,
        builder: (context, _) => MaterialApp.router(
          title: 'Review Funnel · CX-SHIELD',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: widget.theme.mode,
          routerConfig: _router,
          locale: const Locale('vi'),
          supportedLocales: const [Locale('vi'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    );
  }
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Thiếu cấu hình Supabase.\nChạy: flutter run -d chrome --web-port 3000 --dart-define-from-file=config/app.json',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
