import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'core/api/api_client.dart';
import 'core/config/app_config.dart';
import 'core/session/session_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppConfig.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }
  await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabasePublishableKey);
  final theme = await ThemeController.load();
  runApp(CxShieldApp(session: SessionController(api: ApiClient()), theme: theme));
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
