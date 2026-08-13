import 'package:flutter/animation.dart';

class Keyframe<T> {
  final Duration time;
  final T value;
  final Curve curve;

  const Keyframe({
    required this.time,
    required this.value,
    this.curve = Curves.easeInOutCubic, // Use a smooth cinematic default
  });
}
