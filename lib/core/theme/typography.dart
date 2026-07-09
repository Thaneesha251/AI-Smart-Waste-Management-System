import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle heading({double fontSize = 24, Color? color}) => GoogleFonts.poppins(
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.8,
    color: color ?? AppColors.primaryText,
    height: 1.1,
  );

  static TextStyle body({double fontSize = 13, Color color = AppColors.secondaryText}) => GoogleFonts.poppins(
    fontSize: fontSize,
    height: 1.5,
    color: color,
  );

  static TextStyle eyebrow({double fontSize = 11, Color? color}) => GoogleFonts.poppins(
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: color ?? AppColors.mutedText,
  );
}
