import 'package:flutter/material.dart';

/// Trippified color palette - Monochrome with Lime Green accents
abstract final class AppColors {
  // Primary - Black
  static const primary = Color(0xFF1A1A1A);
  static const primaryLight = Color(0xFFF9FAFB);
  static const primaryDark = Color(0xFF111111);

  // Secondary - Dark Gray
  static const secondary = Color(0xFF374151);
  static const secondaryLight = Color(0xFF6B7280);
  static const secondaryDark = Color(0xFF1F2937);

  // Accent - Lime Green
  static const accent = Color(0xFFBFFF00);
  static const accentDark = Color(0xFF9ACD00);

  // Neutrals
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF9FAFB);
  static const surfaceVariant = Color(0xFFF3F4F6);
  static const card = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textOnAccent = Color(0xFF1A1A1A);

  // Semantic
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Border
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const borderDark = Color(0xFFD1D5DB);

  // Shadow
  static const shadow = Color(0x1A000000);

  // Specific UI elements
  static const shimmerBase = Color(0xFFE5E7EB);
  static const shimmerHighlight = Color(0xFFF9FAFB);

  // Day status colors
  static const dayFree = Color(0xFFF3F4F6);
  static const dayGenerated = Color(0xFFECFCCB);
  static const dayCustom = Color(0xFFE0F2FE);

  // Splash screen colors
  static const splashBackground = Color(0xFF0F1A1A);
  static const splashGradientStart = Color(0xFF0A1A1A);
  static const splashGradientEnd = Color(0xFF1A2F2F);
  static const splashButtonBg = Color(0xFF1A2F2F);
  static const splashButtonBorder = Color(0xFF2A4040);

  // Gradient colors (legacy - use splash colors above)
  static const gradientStart = Color(0x00000000);
  static const gradientEnd = Color(0xFF0F4C4C);
}
