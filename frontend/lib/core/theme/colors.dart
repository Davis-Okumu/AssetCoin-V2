import 'package:flutter/material.dart';

abstract final class AppColors {
  // ============================================================
  // BRAND COLORS
  // ============================================================

  /// Main brand blue.
  static const primary = Color(0xFF1565D8);

  /// Deep blue for stronger emphasis.
  static const primaryDark = Color(0xFF0B3D91);

  /// Very light blue for selected states and soft backgrounds.
  static const primaryLight = Color(0xFFEAF3FF);

  /// Bright brand red.
  static const secondary = Color(0xFFE53935);

  /// Deep red for pressed/emphasized states.
  static const secondaryDark = Color(0xFFB71C1C);

  /// Very light red for soft error/action backgrounds.
  static const secondaryLight = Color(0xFFFFEEEE);

  // ============================================================
  // BACKGROUNDS
  // ============================================================

  /// Main application background.
  static const background = Color(0xFFF5F9FF);

  /// Main card/surface color.
  static const surface = Colors.white;

  /// Slightly tinted surface.
  static const surfaceVariant = Color(0xFFF0F5FC);

  // ============================================================
  // TEXT
  // ============================================================

  /// Main text.
  static const textPrimary = Color(0xFF101828);

  /// Secondary text.
  static const textSecondary = Color(0xFF667085);

  /// Muted text.
  static const textMuted = Color(0xFF98A2B3);

  /// Text displayed on dark/colored surfaces.
  static const textOnPrimary = Colors.white;

  // ============================================================
  // BORDERS & DIVIDERS
  // ============================================================

  static const border = Color(0xFFDDE5F0);

  static const divider = Color(0xFFE8EEF6);

  // ============================================================
  // STATUS COLORS
  // ============================================================

  static const success = Color(0xFF12B76A);

  static const successLight = Color(0xFFEAFBF3);

  static const warning = Color(0xFFF79009);

  static const warningLight = Color(0xFFFFF6E5);

  static const error = Color(0xFFE53935);

  static const errorLight = Color(0xFFFFEEEE);

  static const info = Color(0xFF2E90FA);

  static const infoLight = Color(0xFFEDF6FF);

  // ============================================================
  // EXTRA BRAND COLORS
  // ============================================================

  /// Useful for gradients, illustrations and premium cards.
  static const blueAccent = Color(0xFF2979FF);

  static const redAccent = Color(0xFFFF5252);

  /// Dark navy used for premium financial cards.
  static const navy = Color(0xFF0A2540);
}