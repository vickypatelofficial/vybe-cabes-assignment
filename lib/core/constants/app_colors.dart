import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette (Standard Black like typical ride apps)
  static const Color primaryEmerald = Color(0xFF000000); // Kept name to prevent breaking changes
  static const Color primary = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF333333);
  static const Color primaryDark = Color(0xFF000000);

  // Secondary & Accents
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentBlue = Color(0xFF2979FF);
  static const Color accentPurple = Color(0xFF7C4DFF);
  static const Color accentCoral = Color(0xFFFF5252);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF388E3C);

  // Backgrounds & Surfaces (Standard Light Theme)
  static const Color darkMidnight = Color(0xFFF5F5F5); // Kept name, but changed value to light grey
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardSurfaceLight = Color(0xFFF9F9F9);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderGlow = Colors.transparent;
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textTertiary = Color(0xFF757575);

  // Gradients (Simplified to basic subtle shades)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF222222)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
