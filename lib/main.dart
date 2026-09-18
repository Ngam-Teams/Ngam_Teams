// =============================================================================
// main.dart
// Entry point for Ngam Teams – Staff Portal.
// Bootstraps the app, applies the dark glassmorphism theme, and wires GoRouter.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const NgamTeamsApp());
}

class NgamTeamsApp extends StatelessWidget {
  const NgamTeamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ngam Teams',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.darkTheme,
    );
  }
}
