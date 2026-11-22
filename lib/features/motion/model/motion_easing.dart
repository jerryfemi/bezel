/// How the device moves into a keyframe.
///  * spring: physical, settles naturally; [bounce] 0 = no overshoot.
///  * ease: smooth start and stop.
///  * linear: constant speed (good for continuous spins).
enum EasingKind { spring, ease, linear }

class MotionEasing {
  const MotionEasing(this.kind, {this.bounce = 0});

  static const spring = MotionEasing(EasingKind.spring);
  static const ease = MotionEasing(EasingKind.ease);
  static const linear = MotionEasing(EasingKind.linear);

  final EasingKind kind;

  /// 0..0.5, only used by springs.
  final double bounce;

  Map<String, Object> toJson() => {'kind': kind.name, 'bounce': bounce};
}
