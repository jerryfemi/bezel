import 'dart:ui';
import 'keyframe.dart';
import 'scene_state.dart';

class Timeline {
  final List<Keyframe<double>> positionX;
  final List<Keyframe<double>> positionY;
  final List<Keyframe<double>> scale;
  final List<Keyframe<double>> rotation;
  final List<Keyframe<double>> opacity;
  final Duration duration;

  const Timeline({
    this.positionX = const [],
    this.positionY = const [],
    this.scale = const [],
    this.rotation = const [],
    this.opacity = const [],
    required this.duration,
  });

  SceneState evaluateAt(Duration time, {required SceneState baseState}) {
    // If the timeline is empty, return the base state
    if (positionX.isEmpty &&
        positionY.isEmpty &&
        scale.isEmpty &&
        rotation.isEmpty &&
        opacity.isEmpty) {
      return baseState;
    }

    return baseState.copyWith(
      positionX: _evaluateProperty(positionX, time) ?? baseState.positionX,
      positionY: _evaluateProperty(positionY, time) ?? baseState.positionY,
      scale: _evaluateProperty(scale, time) ?? baseState.scale,
      rotation: _evaluateProperty(rotation, time) ?? baseState.rotation,
      opacity: _evaluateProperty(opacity, time) ?? baseState.opacity,
    );
  }

  double? _evaluateProperty(List<Keyframe<double>> keyframes, Duration time) {
    if (keyframes.isEmpty) return null;

    // If time is before the first keyframe, return first value
    if (time <= keyframes.first.time) {
      return keyframes.first.value;
    }

    // If time is after the last keyframe, return last value
    if (time >= keyframes.last.time) {
      return keyframes.last.value;
    }

    // Find the two keyframes surrounding the current time
    for (int i = 0; i < keyframes.length - 1; i++) {
      final kf1 = keyframes[i];
      final kf2 = keyframes[i + 1];

      if (time >= kf1.time && time <= kf2.time) {
        // Calculate the raw progress between the two keyframes
        final segmentDuration = kf2.time.inMicroseconds - kf1.time.inMicroseconds;
        final elapsedTime = time.inMicroseconds - kf1.time.inMicroseconds;
        final rawProgress = elapsedTime / segmentDuration;

        // Apply the easing curve of the second keyframe (or first depending on convention, we'll use kf2's curve)
        final easedProgress = kf2.curve.transform(rawProgress);

        // Interpolate the value
        return lerpDouble(kf1.value, kf2.value, easedProgress)!;
      }
    }

    return null; // Should not be reached
  }
}
