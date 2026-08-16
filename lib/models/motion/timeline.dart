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

  Timeline copyWith({
    List<Keyframe<double>>? positionX,
    List<Keyframe<double>>? positionY,
    List<Keyframe<double>>? scale,
    List<Keyframe<double>>? rotation,
    List<Keyframe<double>>? opacity,
    Duration? duration,
  }) {
    return Timeline(
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      duration: duration ?? this.duration,
    );
  }

  List<Keyframe<double>> _upsertKeyframe(
    List<Keyframe<double>> list,
    Duration time,
    double value,
  ) {
    final newList = List<Keyframe<double>>.from(list);
    final index = newList.indexWhere((k) => k.time == time);
    if (index >= 0) {
      newList[index] = Keyframe(
        time: time,
        value: value,
        curve: newList[index].curve,
      );
    } else {
      newList.add(Keyframe(time: time, value: value));
      newList.sort((a, b) => a.time.compareTo(b.time));
    }
    return newList;
  }

  Timeline withUpdatedProperty({
    double? positionX,
    double? positionY,
    double? scale,
    double? rotation,
    double? opacity,
    required Duration time,
  }) {
    return copyWith(
      positionX: positionX != null
          ? _upsertKeyframe(this.positionX, time, positionX)
          : null,
      positionY: positionY != null
          ? _upsertKeyframe(this.positionY, time, positionY)
          : null,
      scale: scale != null ? _upsertKeyframe(this.scale, time, scale) : null,
      rotation: rotation != null
          ? _upsertKeyframe(this.rotation, time, rotation)
          : null,
      opacity: opacity != null
          ? _upsertKeyframe(this.opacity, time, opacity)
          : null,
    );
  }

  /// Rescales all keyframe timestamps proportionally so the animation
  /// spans the entire [newDuration] with zero dead time.
  Timeline withScaledDuration(Duration newDuration) {
    if (duration.inMicroseconds == 0) return copyWith(duration: newDuration);

    final ratio = newDuration.inMicroseconds / duration.inMicroseconds;

    List<Keyframe<double>> scaleKfs(List<Keyframe<double>> kfs) {
      return kfs.map((k) {
        return Keyframe<double>(
          time: Duration(
            microseconds: (k.time.inMicroseconds * ratio).round(),
          ),
          value: k.value,
          curve: k.curve,
        );
      }).toList();
    }

    return Timeline(
      positionX: scaleKfs(positionX),
      positionY: scaleKfs(positionY),
      scale: scaleKfs(scale),
      rotation: scaleKfs(rotation),
      opacity: scaleKfs(opacity),
      duration: newDuration,
    );
  }

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
        final segmentDuration =
            kf2.time.inMicroseconds - kf1.time.inMicroseconds;
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
