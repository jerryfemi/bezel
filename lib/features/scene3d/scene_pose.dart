/// How the device is turned, in degrees.
/// [turn] spins around the vertical axis; [tilt] leans the top toward the viewer.
class ScenePose {
  const ScenePose({this.turn = 0, this.tilt = 0});

  final double turn;
  final double tilt;

  ScenePose copyWith({double? turn, double? tilt}) =>
      ScenePose(turn: turn ?? this.turn, tilt: tilt ?? this.tilt);
}
