import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../scene3d/scene_specs.dart';

/// Flutter text styles that match the canvas caption (web/scene/caption.js),
/// used for the typeface previews and for editing the text in place.
class CaptionFontStyle {
  const CaptionFontStyle._();

  /// Headline size as a fraction of the frame's shorter side, per typeface.
  static double headlineScale(CaptionFont f) => switch (f) {
        CaptionFont.bricolage => 0.08,
        CaptionFont.archivo => 0.07,
        CaptionFont.inter => 0.075,
        CaptionFont.instrumentSerif => 0.09,
      };

  static TextStyle headline(CaptionFont f, double size, Color color) {
    final (family, weight, tracking, height) = switch (f) {
      CaptionFont.bricolage => ('Bricolage Grotesque', FontWeight.w800, -0.035, 0.95),
      CaptionFont.archivo => ('Archivo', FontWeight.w900, -0.03, 1.02),
      CaptionFont.inter => ('Inter', FontWeight.w700, -0.025, 1.05),
      CaptionFont.instrumentSerif => ('Instrument Serif', FontWeight.w400, -0.01, 1.0),
    };
    return _font(family, TextStyle(
      fontSize: size, fontWeight: weight, letterSpacing: tracking * size, height: height, color: color));
  }

  static TextStyle subtitle(CaptionFont f, double size, Color color) {
    final family = f == CaptionFont.bricolage || f == CaptionFont.instrumentSerif
        ? 'Instrument Sans'
        : 'Inter';
    return _font(family, TextStyle(fontSize: size, height: 1.45, color: color));
  }

  static TextStyle _font(String family, TextStyle base) {
    try {
      return GoogleFonts.getFont(family, textStyle: base);
    } catch (_) {
      return GoogleFonts.inter(textStyle: base); // older google_fonts without this family
    }
  }
}
