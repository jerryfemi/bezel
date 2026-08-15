import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings (Space Grotesk)
  static TextStyle get headingLarge => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static TextStyle get headingMedium => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  // UI / Body (Inter)
  static TextStyle get uiBody => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryText,
  );

  static TextStyle get uiBodySecondary => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

  static TextStyle get uiLabel => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static TextStyle get panelHeader => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.secondaryText,
  );

  // Technical / Numeric (IBM Plex Mono)
  static TextStyle get technical => GoogleFonts.ibmPlexMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static TextStyle get technicalSubtle => GoogleFonts.ibmPlexMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );
}
