class SceneState {
  // Device-level properties
  final double positionX;
  final double positionY;
  final double scale;
  final double rotation;
  final double opacity;

  const SceneState({
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
  });

  SceneState copyWith({
    double? positionX,
    double? positionY,
    double? scale,
    double? rotation,
    double? opacity,
  }) {
    return SceneState(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
    );
  }
}
