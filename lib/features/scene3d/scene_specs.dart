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

/// The two pieces of a caption. Each can be moved, sized and edited.
enum CaptionPart { headline, subtitle }

class CaptionSpec {
  const CaptionSpec({
    required this.enabled,
    required this.headline,
    required this.subtitle,
    required this.side,
    this.font = CaptionFont.bricolage,
    this.align = CaptionAlign.left,
    this.size = 1,
    this.subSize = 1,
    this.dx = 0,
    this.dy = 0,
    this.subDx = 0,
    this.subDy = 0,
    this.editing,
  });

  final bool enabled;
  final String headline;
  final String subtitle;
  final CaptionSide side;
  final CaptionFont font;
  final CaptionAlign align;

  /// Headline and subtitle scale; 1 is the default size.
  final double size;
  final double subSize;

  /// Offset of the whole caption from its layout spot, as fractions of the frame.
  final double dx;
  final double dy;

  /// Extra offset of the subtitle alone, once pulled away from the headline.
  final double subDx;
  final double subDy;

  /// The part being typed on the canvas (the scene hides it), if any.
  final CaptionPart? editing;

  bool get moved => dx != 0 || dy != 0 || subDx != 0 || subDy != 0;

  CaptionSpec copyWith({
    bool? enabled, String? headline, String? subtitle, CaptionSide? side, CaptionFont? font,
    CaptionAlign? align, double? size, double? subSize, double? dx, double? dy,
    double? subDx, double? subDy, CaptionPart? Function()? editing,
  }) =>
      CaptionSpec(
        enabled: enabled ?? this.enabled,
        headline: headline ?? this.headline,
        subtitle: subtitle ?? this.subtitle,
        side: side ?? this.side,
        font: font ?? this.font,
        align: align ?? this.align,
        size: size ?? this.size,
        subSize: subSize ?? this.subSize,
        dx: dx ?? this.dx,
        dy: dy ?? this.dy,
        subDx: subDx ?? this.subDx,
        subDy: subDy ?? this.subDy,
        editing: editing != null ? editing() : this.editing,
      );

  /// Saved form (no editing state).
  Map<String, Object> toMap() => {
        'enabled': enabled,
        'headline': headline,
        'subtitle': subtitle,
        'side': side.name,
        'font': font.name,
        'align': align.name,
        'size': size,
        'subSize': subSize,
        'dx': dx,
        'dy': dy,
        'subDx': subDx,
        'subDy': subDy,
      };

  factory CaptionSpec.fromMap(Map<String, dynamic> m) {
    double d(String k) => (m[k] as num?)?.toDouble() ?? 0;
    T pick<T extends Enum>(List<T> values, String k, T fallback) {
      for (final v in values) {
        if (v.name == m[k]) return v;
      }
      return fallback;
    }
    return CaptionSpec(
      enabled: m['enabled'] == true,
      headline: m['headline'] as String? ?? '',
      subtitle: m['subtitle'] as String? ?? '',
      side: pick(CaptionSide.values, 'side', CaptionSide.left),
      font: pick(CaptionFont.values, 'font', CaptionFont.bricolage),
      align: pick(CaptionAlign.values, 'align', CaptionAlign.left),
      size: (m['size'] as num?)?.toDouble() ?? 1,
      subSize: (m['subSize'] as num?)?.toDouble() ?? 1,
      dx: d('dx'),
      dy: d('dy'),
      subDx: d('subDx'),
      subDy: d('subDy'),
    );
  }

  String toJson() => jsonEncode({...toMap(), 'hidden': editing?.name});
}

class LightSpec {
  const LightSpec({required this.angle, required this.intensity, required this.reflections});

  /// Where the light comes from, like a clock face: 0 top, 90 right.
  final double angle;

  /// 0..1.
  final double intensity;
  final bool reflections;

  Map<String, Object> toMap() =>
      {'angle': angle, 'intensity': intensity, 'reflections': reflections};

  factory LightSpec.fromMap(Map<String, dynamic> m) => LightSpec(
        angle: (m['angle'] as num?)?.toDouble() ?? 315,
        intensity: (m['intensity'] as num?)?.toDouble() ?? 0.6,
        reflections: m['reflections'] != false,
      );

  String toJson() => jsonEncode(toMap());
}
