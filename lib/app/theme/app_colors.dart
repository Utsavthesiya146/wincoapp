import 'package:flutter/material.dart';

/// WINCO Connect Official Brand Colors
/// Strict adherence to the corporate guidelines:
/// Primary Burgundy: #702321
/// Secondary Burgundy: #8A302D
/// Accent Orange: #F28C00
/// Light Background: #F7F7F8
/// White: #FFFFFF
/// Primary Text: #252525
/// Secondary Text: #777777
/// Border: #EAEAEA
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primaryBurgundy = Color(0xFF702321);
  static const Color secondaryBurgundy = Color(0xFF8A302D);
  static const Color darkBurgundy = Color(0xFF4A1413);
  static const Color lightBurgundy = Color(0xFF8E3734);
  static const Color wineGradientEnd = Color(0xFF561A19);

  // Accent Colors
  static const Color accentOrange = Color(0xFFF28C00);
  static const Color accentOrangeLight = Color(0xFFFFF3E0);
  static const Color goldAccent = Color(0xFFD4AF37);

  // Backgrounds & Surfaces
  static const Color lightBackground = Color(0xFFF7F7F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F2F4);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Typography Colors
  static const Color textPrimary = Color(0xFF252525);
  static const Color textSecondary = Color(0xFF777777);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFE5A823);

  // Borders & Dividers
  static const Color border = Color(0xFFEAEAEA);
  static const Color borderDark = Color(0xFFD0D0D0);
  static const Color divider = Color(0xFFEEEEEE);

  // Functional Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Shimmer & Skeleton
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradients
  static const LinearGradient burgundyGradient = LinearGradient(
    colors: [primaryBurgundy, secondaryBurgundy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBurgundyGradient = LinearGradient(
    colors: [primaryBurgundy, wineGradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primeClubGradient = LinearGradient(
    colors: [Color(0xFF2B0B0A), Color(0xFF5A1918), Color(0xFF702321)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeAccentGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFF28C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

