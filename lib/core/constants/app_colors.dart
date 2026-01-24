import 'package:flutter/material.dart';

/// Trippified color palette - Chocolate & Burgundy tones
abstract final class AppColors {
  // Primary - Chocolate Brown
  static const primary = Color(0xFF5D3A1A);
  static const primaryLight = Color(0xFF8B5A3C);
  static const primaryDark = Color(0xFF3D2314);

  // Secondary - Burgundy/Maroon
  static const secondary = Color(0xFF6B2D3C);
  static const secondaryLight = Color(0xFF8B4D5C);
  static const secondaryDark = Color(0xFF4A1D2C);

  // Accent - Wine/Purple-Brown
  static const accent = Color(0xFF7A3E4D);

  // Neutrals
  static const background = Color(0xFFFCF9F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF7F3EF);
  static const card = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF2D2D2D);
  static const textSecondary = Color(0xFF6B6B6B);
  static const textTertiary = Color(0xFF9B9B9B);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF42A5F5);

  // Border
  static const border = Color(0xFFE0DCD7);
  static const borderLight = Color(0xFFF0EDE9);

  // Shadow
  static const shadow = Color(0x1A000000);

  // Specific UI elements
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);

  // Day status colors
  static const dayFree = Color(0xFFF0EBE6);
  static const dayGenerated = Color(0xFFE8D8DC);
  static const dayCustom = Color(0xFFE5DDD0);
}
