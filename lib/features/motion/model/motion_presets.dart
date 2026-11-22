import '../../scene3d/scene_pose.dart';
import 'keyframe.dart';
import 'motion_easing.dart';

/// A ready-made move. [build] turns it into keyframes that continue from the
/// pose the clip currently ends on, starting at [start] seconds.
class MotionPreset {
  const MotionPreset(this.name, this.description, this.build);

  final String name;
  final String description;
  final List<Keyframe> Function(ScenePose from, double start, String Function() newId) build;
}

Keyframe _key(String Function() id, double t, ScenePose p, [MotionEasing e = MotionEasing.spring]) =>
    Keyframe(id: id(), time: t, pose: p, easing: e);

final motionPresets = [
  MotionPreset('Tilt in', 'Leans up from flat', (from, s, id) => [
        _key(id, s + 0.01, from.copyWith(tilt: 55, zoom: from.zoom * 0.85), MotionEasing.linear),
        _key(id, s + 1.5, from, const MotionEasing(EasingKind.spring, bounce: 0.15)),
      ]),
  MotionPreset('Turn reveal', 'Slow turn to face you', (from, s, id) => [
        _key(id, s + 3, from.copyWith(turn: from.turn + 40), MotionEasing.ease),
      ]),
  MotionPreset('Float', 'Gentle hover, loops well', (from, s, id) => [
        _key(id, s + 1, from.copyWith(tilt: from.tilt + 4, turn: from.turn + 3), MotionEasing.ease),
        _key(id, s + 2, from, MotionEasing.ease),
      ]),
  MotionPreset('Orbit', 'Full 360° spin', (from, s, id) => [
        _key(id, s + 4, from.copyWith(turn: from.turn + 360), MotionEasing.ease),
      ]),
  MotionPreset('Drop and settle', 'Falls in with a bounce', (from, s, id) => [
        _key(id, s + 0.01, from.copyWith(zoom: from.zoom * 1.35, tilt: from.tilt - 12), MotionEasing.linear),
        _key(id, s + 1.2, from, const MotionEasing(EasingKind.spring, bounce: 0.35)),
      ]),
  MotionPreset('Push in', 'Camera moves to the screen', (from, s, id) => [
        _key(id, s + 2.5, from.copyWith(turn: 0, tilt: 0, zoom: from.zoom * 1.7), MotionEasing.ease),
      ]),
];
