import 'dart:convert';

/// Settings sent to the 3D scene. Each mirrors a JSON shape documented in
/// web/scene/bezel_scene.js.

enum BackgroundStyle { solid, spotlight, image }

class BackgroundSpec {
  const BackgroundSpec({required this.style, required this.colorHex, this.imageUrl});

  final BackgroundStyle style;
  final String colorHex;
  final String? imageUrl;

  String toJson() => jsonEncode({
        'style': style.name,
        'color': colorHex,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
}

enum CaptionSide { left, above, right }

/// Caption typefaces; [id]s match STYLES in web/scene/caption.js.
enum CaptionFont {
  bricolage('Bricolage Grotesque'),
  archivo('Archivo Expanded'),
  inter('Inter'),
  instrumentSerif('Instrument Serif');

  const CaptionFont(this.label);

  final String label;
}

enum CaptionAlign { left, center, right }

class CaptionSpec {
  const CaptionSpec({
    required this.enabled,
    required this.headline,
    required this.subtitle,
    required this.side,
    this.font = CaptionFont.bricolage,
    this.align = CaptionAlign.left,
    this.size = 1,
    this.dx = 0,
    this.dy = 0,
    this.editing = false,
  });

  final bool enabled;
  final String headline;
  final String subtitle;
  final CaptionSide side;
  final CaptionFont font;
  final CaptionAlign align;

  /// Text scale; 1 is the default size.
  final double size;

  /// Offset from the layout position, as fractions of the frame.
  final double dx;
  final double dy;

  /// True while the text is being edited on the canvas (the scene hides it).
  final bool editing;

  bool get moved => dx != 0 || dy != 0;

  CaptionSpec copyWith({
    bool? enabled, String? headline, String? subtitle, CaptionSide? side, CaptionFont? font,
    CaptionAlign? align, double? size, double? dx, double? dy, bool? editing,
  }) =>
      CaptionSpec(
        enabled: enabled ?? this.enabled,
        headline: headline ?? this.headline,
        subtitle: subtitle ?? this.subtitle,
        side: side ?? this.side,
        font: font ?? this.font,
        align: align ?? this.align,
        size: size ?? this.size,
        dx: dx ?? this.dx,
        dy: dy ?? this.dy,
        editing: editing ?? this.editing,
      );

  String toJson() => jsonEncode({
        'enabled': enabled,
        'headline': headline,
        'subtitle': subtitle,
        'side': side.name,
        'font': font.name,
        'align': align.name,
        'size': size,
        'dx': dx,
        'dy': dy,
        'hidden': editing,
      });
}

class LightSpec {
  const LightSpec({required this.angle, required this.intensity, required this.reflections});

  /// Where the light comes from, like a clock face: 0 top, 90 right.
  final double angle;

  /// 0..1.
  final double intensity;
  final bool reflections;

  String toJson() =>
      jsonEncode({'angle': angle, 'intensity': intensity, 'reflections': reflections});
}
