import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bezel_colors.dart';

/// Material theme for the parts of Bezel that use stock widgets
/// (menus, tooltips, text fields, sliders).
ThemeData buildBezelTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: BezelColors.canvas,
    colorScheme: base.colorScheme.copyWith(
      primary: BezelColors.accentLine,
      surface: BezelColors.surfaceRaised,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    tooltipTheme: const TooltipThemeData(
      waitDuration: Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A30),
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 3,
      activeTrackColor: BezelColors.textPrimary,
      inactiveTrackColor: BezelColors.strokeStrong,
      thumbColor: BezelColors.textPrimary,
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      color: Color(0xFF232328),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  );
}
