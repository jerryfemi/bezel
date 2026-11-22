import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:bezel/features/motion/model/keyframe.dart';
import 'package:bezel/features/motion/model/motion_presets.dart';
import 'package:bezel/features/motion/model/motion_timeline.dart';
import 'package:bezel/features/motion/widgets/format_time.dart';
import 'package:bezel/features/scene3d/scene_pose.dart';

void main() {
  test('keyframes are kept in time order and set the duration', () {
    final timeline = const MotionTimeline().withKeyframes([
      const Keyframe(id: 'b', time: 3, pose: ScenePose(turn: 20)),
      const Keyframe(id: 'a', time: 0, pose: ScenePose()),
    ]);
    expect(timeline.keyframes.map((k) => k.id), ['a', 'b']);
    expect(timeline.duration, 3);
    expect(timeline.isEmpty, isFalse);
  });

  test('timeline JSON matches what the scene player reads', () {
    final timeline = const MotionTimeline().withKeyframes([
      const Keyframe(id: 'a', time: 1.5, pose: ScenePose(turn: 10, tilt: 5, zoom: 1.2)),
    ]);
    final json = jsonDecode(timeline.toJson()) as Map<String, dynamic>;
    final key = (json['keyframes'] as List).single as Map<String, dynamic>;
    expect(json['loop'], isTrue);
    expect(key['time'], 1.5);
    expect(key['zoom'], 1.2);
    expect((key['easing'] as Map)['kind'], 'spring');
  });

  test('presets continue from the given pose and time', () {
    var n = 0;
    final orbit = motionPresets.firstWhere((p) => p.name == 'Orbit');
    final keys = orbit.build(const ScenePose(turn: 10), 2, () => 'k${n++}');
    expect(keys.single.time, 6);
    expect(keys.single.pose.turn, 370);
  });

  test('clip time formats as m:ss.s', () {
    expect(formatClipTime(0), '0:00.0');
    expect(formatClipTime(1.24), '0:01.2');
    expect(formatClipTime(75.5), '1:15.5');
  });
}
