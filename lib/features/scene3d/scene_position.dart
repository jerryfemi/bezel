/// Where the device sits on the output artboard, relative to its center.
/// Values are fractions of the artboard width and height, so placement scales
/// with the selected frame shape and export resolution.
class ScenePosition {
  const ScenePosition({this.x = 0, this.y = 0});

  final double x;
  final double y;
}
