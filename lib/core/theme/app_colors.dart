import 'package:flutter/material.dart';

/// Centralized color constants for Ngam Teams.
/// Matches the dark glassmorphism palette from Ngam Admin / Business.
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

  // ─── Surfaces ───────────────────────────────────────────────
  static const Color background = Color(0xFF0A0A14);
  static const Color surface = Color(0xFF1E1E2C);
  static const Color surfaceLight = Color(0xFF252536);
  static const Color cardBg = Color(0xFF1A1A28);

  // ─── Text ───────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white38;

  // ─── Glass Effects ──────────────────────────────────────────
  static Color glassBackground = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.15);
  static Color glassHover = Colors.white.withValues(alpha: 0.08);
}
