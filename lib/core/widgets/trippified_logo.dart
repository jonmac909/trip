import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:trippified/core/constants/app_colors.dart';

/// Trippified text logo with elegant script styling
class TrippifiedLogo extends StatelessWidget {
  const TrippifiedLogo({
    super.key,
    this.fontSize = 28,
    this.color,
  });

  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Trippified',
      style: GoogleFonts.playfairDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}
