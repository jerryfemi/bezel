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

class CaptionSpec {
  const CaptionSpec({
    required this.enabled,
    required this.headline,
    required this.subtitle,
    required this.side,
  });

  final bool enabled;
  final String headline;
  final String subtitle;
  final CaptionSide side;

  String toJson() => jsonEncode({
        'enabled': enabled,
        'headline': headline,
        'subtitle': subtitle,
        'side': side.name,
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
