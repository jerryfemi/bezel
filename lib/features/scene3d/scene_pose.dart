/// How the device is turned and zoomed.
/// [turn] spins around the vertical axis and [tilt] leans the top toward the
/// viewer (both degrees); [zoom] scales the device (1 = default size).
class ScenePose {
  const ScenePose({this.turn = 0, this.tilt = 0, this.zoom = 1});

  final double turn;
  final double tilt;
  final double zoom;

  ScenePose copyWith({double? turn, double? tilt, double? zoom}) =>
      ScenePose(turn: turn ?? this.turn, tilt: tilt ?? this.tilt, zoom: zoom ?? this.zoom);
}
