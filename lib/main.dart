// =============================================================================
// main.dart
// Entry point for Ngam Teams – Staff Portal.
// Bootstraps the app, applies dynamic themes & localizations, and wires GoRouter.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/state/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and pre-warm Liquid Glass shader pipeline (prevents dim/glitch on first load)
  await LiquidGlassWidgets.initialize();

  // Initialize persisted theme & localization preferences
  await AppSettings.instance.init();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Falls back gracefully if .env is missing in fresh clone or test runner
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://rsueaoglsdxhzpupjljd.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_qP4whY5B6wxIasWOVGoPCw_vrhOXj_J';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  runApp(const NgamTeamsApp());
}

class NgamTeamsApp extends StatelessWidget {
  const NgamTeamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Ngam Teams',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppSettings.instance.themeMode,
          locale: AppSettings.instance.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ms'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
