import '../../scene3d/scene_pose.dart';
import 'motion_easing.dart';

/// The device's pose at a moment in time, and how it moves into it.
class Keyframe {
  const Keyframe({
    required this.id,
    required this.time,
    required this.pose,
    this.easing = MotionEasing.spring,
  });

  final String id;

  /// Seconds from the start of the clip.
  final double time;
  final ScenePose pose;
  final MotionEasing easing;

  Keyframe copyWith({double? time, ScenePose? pose, MotionEasing? easing}) => Keyframe(
        id: id,
        time: time ?? this.time,
        pose: pose ?? this.pose,
        easing: easing ?? this.easing,
      );

  Map<String, Object> toJson() => {
        'time': time,
        'turn': pose.turn,
        'tilt': pose.tilt,
        'zoom': pose.zoom,
        'easing': easing.toJson(),
      };

  /// Reads the map written by [toJson]; [id] is assigned fresh.
  factory Keyframe.fromMap(String id, Map<String, dynamic> m) {
    double n(String k, double fallback) => (m[k] as num?)?.toDouble() ?? fallback;
    return Keyframe(
      id: id,
      time: n('time', 0),
      pose: ScenePose(turn: n('turn', 0), tilt: n('tilt', 0), zoom: n('zoom', 1)),
      easing: m['easing'] is Map
          ? MotionEasing.fromMap((m['easing'] as Map).cast<String, dynamic>())
          : MotionEasing.spring,
    );
  }
}
