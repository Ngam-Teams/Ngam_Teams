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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NgamTeamsApp());
}

class NgamTeamsApp extends StatefulWidget {
  const NgamTeamsApp({super.key});

  @override
  State<NgamTeamsApp> createState() => _NgamTeamsAppState();
}

class _NgamTeamsAppState extends State<NgamTeamsApp> {
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Initialize shader pipeline & preferences concurrently
    await Future.wait([
      LiquidGlassWidgets.initialize().catchError((e) {
        debugPrint('LiquidGlass init error: $e');
      }),
      AppSettings.instance.init().catchError((e) {
        debugPrint('AppSettings init error: $e');
      }),
    ]);

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://rsueaoglsdxhzpupjljd.supabase.co';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'sb_publishable_qP4whY5B6wxIasWOVGoPCw_vrhOXj_J';

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0F172A),
            ),
            home: const Scaffold(
              backgroundColor: Color(0xFF0F172A),
              body: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ),
            ),
          );
        }

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
      },
    );
  }
}
