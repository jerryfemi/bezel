import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bezel_colors.dart';

/// Type scale. Large text tracks tighter, small text slightly looser.
abstract final class BezelType {
  static TextStyle get brand => GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.15,
      color: BezelColors.textPrimary);

  static TextStyle get title => GoogleFonts.inter(
      fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1,
      color: BezelColors.textPrimary);

  static TextStyle get body => GoogleFonts.inter(
      fontSize: 13, fontWeight: FontWeight.w400, color: BezelColors.textPrimary);

  static TextStyle get label => GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w500, color: BezelColors.textPrimary);

  static TextStyle get section => GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w600, color: BezelColors.textSecondary);

  static TextStyle get caption => GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.1,
      color: BezelColors.textSecondary);

  static TextStyle get mono => GoogleFonts.ibmPlexMono(
      fontSize: 12, fontWeight: FontWeight.w500, color: BezelColors.textPrimary);
}
