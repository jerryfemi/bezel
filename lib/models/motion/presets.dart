import 'package:flutter/animation.dart';
import 'keyframe.dart';
import 'timeline.dart';

class MotionPresets {
  static const Duration _defaultDuration = Duration(seconds: 5);

  static Timeline pushIn() {
    return Timeline(
      duration: _defaultDuration,
      scale: [
        const Keyframe(time: Duration.zero, value: 0.8),
        Keyframe(time: _defaultDuration, value: 1.05),
      ],
    );
  }

  static Timeline pullOut() {
    return Timeline(
      duration: _defaultDuration,
      scale: [
        const Keyframe(time: Duration.zero, value: 1.05),
        Keyframe(time: _defaultDuration, value: 0.85),
      ],
    );
  }

  static Timeline panUp() {
    return Timeline(
      duration: _defaultDuration,
      positionY: [
        const Keyframe(time: Duration.zero, value: 60.0),
        Keyframe(time: _defaultDuration, value: 0.0),
      ],
    );
  }

  static Timeline panDown() {
    return Timeline(
      duration: _defaultDuration,
      positionY: [
        const Keyframe(time: Duration.zero, value: -60.0),
        Keyframe(time: _defaultDuration, value: 0.0),
      ],
    );
  }

  static Timeline twist() {
    return Timeline(
      duration: _defaultDuration,
      rotation: [
        const Keyframe(time: Duration.zero, value: -0.087), // ~ -5 degrees
        Keyframe(time: _defaultDuration, value: 0.087),     // ~ 5 degrees
      ],
    );
  }

  static Timeline reveal() {
    return Timeline(
      duration: _defaultDuration,
      scale: [
        const Keyframe(time: Duration.zero, value: 0.9),
        const Keyframe(time: Duration(seconds: 2), value: 1.0, curve: Curves.easeOutCubic),
        Keyframe(time: _defaultDuration, value: 1.0),
      ],
      rotation: [
        const Keyframe(time: Duration.zero, value: -0.104), // ~ -6 degrees
        const Keyframe(time: Duration(seconds: 2), value: 0.0, curve: Curves.easeOutCubic),
        Keyframe(time: _defaultDuration, value: 0.0),
      ],
      positionY: [
        const Keyframe(time: Duration.zero, value: 50.0),
        const Keyframe(time: Duration(seconds: 2), value: 0.0, curve: Curves.easeOutCubic),
        Keyframe(time: _defaultDuration, value: 0.0),
      ],
      opacity: [
        const Keyframe(time: Duration.zero, value: 0.0),
        const Keyframe(time: Duration(seconds: 1), value: 1.0),
        Keyframe(time: _defaultDuration, value: 1.0),
      ],
    );
  }

  static Timeline hero() {
    return Timeline(
      duration: _defaultDuration,
      scale: [
        const Keyframe(time: Duration.zero, value: 0.88),
        Keyframe(time: _defaultDuration, value: 1.04),
      ],
      positionY: [
        const Keyframe(time: Duration.zero, value: 30.0),
        Keyframe(time: _defaultDuration, value: 0.0),
      ],
      rotation: [
        const Keyframe(time: Duration.zero, value: -0.052), // ~ -3 degrees
        Keyframe(time: _defaultDuration, value: 0.052),     // ~ 3 degrees
      ],
    );
  }

  static final List<Map<String, dynamic>> allPresets = [
    {'name': 'Push In', 'timeline': pushIn()},
    {'name': 'Pull Out', 'timeline': pullOut()},
    {'name': 'Pan Up', 'timeline': panUp()},
    {'name': 'Pan Down', 'timeline': panDown()},
    {'name': 'Twist', 'timeline': twist()},
    {'name': 'Reveal', 'timeline': reveal()},
    {'name': 'Hero', 'timeline': hero()},
  ];
}
