import 'package:flutter/painting.dart';

/// Solid scene backgrounds. Gradients and images come with the Background phase.
class SceneBackground {
  const SceneBackground(this.name, this.color);

  final String name;
  final Color color;

  String get hex =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}

const sceneBackgrounds = [
  SceneBackground('Dusk', Color(0xFF1A1F2B)),
  SceneBackground('Paper', Color(0xFFEDEBE6)),
  SceneBackground('Plum', Color(0xFF2A1F3D)),
  SceneBackground('Sand', Color(0xFFE8DCCB)),
  SceneBackground('Forest', Color(0xFF12352E)),
  SceneBackground('Ink', Color(0xFF0A0A0C)),
];
