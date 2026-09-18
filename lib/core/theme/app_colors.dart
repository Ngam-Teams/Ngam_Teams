import 'package:flutter/material.dart';

/// Centralized color constants for Ngam Teams.
/// Supports both dark glassmorphism and modern clean light glass palette.
class AppColors {
  AppColors._();

  // ─── Brand ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF42A5F5);
  static const Color accent = Color(0xFF42A5F5);

  // ─── Semantic ───────────────────────────────────────────────
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // ─── Surfaces (Dark Defaults) ────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A14);
  static const Color darkSurface = Color(0xFF161624);
  static const Color darkSurfaceLight = Color(0xFF202032);
  static const Color darkCardBg = Color(0xFF1A1A28);

  // ─── Surfaces (Light Defaults) ───────────────────────────────
  static const Color lightBackground = Color(0xFFF4F6FB);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceLight = Color(0xFFF8FAFC);
  static const Color lightCardBg = Colors.white;

  // ─── Legacy Static aliases for backward compatibility ────────
  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceLight = darkSurfaceLight;
  static const Color cardBg = darkCardBg;

  // ─── Text ───────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white38;

  // ─── Glass Effects ──────────────────────────────────────────
  static Color glassBackground = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.15);
  static Color glassHover = Colors.white.withValues(alpha: 0.08);

  // ─── Adaptive Helpers ───────────────────────────────────────
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : lightBackground;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCardBg
          : lightCardBg;

  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1E293B);

  static Color subtext(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white60
          : const Color(0xFF64748B);

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.08);

  static Color glass(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white.withValues(alpha: 0.7);
}
