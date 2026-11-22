import 'dart:convert';

import 'keyframe.dart';

/// The clip's motion: keyframes in time order. Between two keyframes the
/// device moves from one pose to the next using the later one's easing.
class MotionTimeline {
  const MotionTimeline({this.keyframes = const [], this.loop = true});

  final List<Keyframe> keyframes;
  final bool loop;

  bool get isEmpty => keyframes.length < 2;

  /// Clip length: the last keyframe's time.
  double get duration => keyframes.isEmpty ? 0 : keyframes.last.time;

  Keyframe? byId(String? id) {
    for (final k in keyframes) {
      if (k.id == id) return k;
    }
    return null;
  }

  MotionTimeline withKeyframes(List<Keyframe> next) =>
      MotionTimeline(keyframes: [...next]..sort((a, b) => a.time.compareTo(b.time)), loop: loop);

  MotionTimeline withLoop(bool value) => MotionTimeline(keyframes: keyframes, loop: value);

  String toJson() => jsonEncode({
        'loop': loop,
        'keyframes': [for (final k in keyframes) k.toJson()],
      });
}
