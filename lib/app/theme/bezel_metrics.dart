/// Spacing and corner radii. Bigger surfaces get bigger radii.
abstract final class BezelSpace {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const edge = 14.0; // gap between floating chrome and the window edge

  /// The whole app is drawn at this size (1 = no scaling).
  static const uiScale = 0.8;
}

abstract final class BezelRadius {
  static const chip = 8.0;
  static const control = 10.0;
  static const dock = 16.0;
  static const panel = 18.0;
}
