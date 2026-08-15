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

  static Timeline slam() {
    return Timeline(
      duration: _defaultDuration,
      scale: [
        const Keyframe(time: Duration.zero, value: 3.0),
        const Keyframe(time: Duration(milliseconds: 800), value: 0.9, curve: Curves.easeOutBack),
        Keyframe(time: _defaultDuration, value: 1.0),
      ],
      opacity: [
        const Keyframe(time: Duration.zero, value: 0.0),
        const Keyframe(time: Duration(milliseconds: 300), value: 1.0),
      ],
    );
  }

  static Timeline float() {
    return Timeline(
      duration: _defaultDuration,
      positionY: [
        const Keyframe(time: Duration.zero, value: 0.0),
        const Keyframe(time: Duration(milliseconds: 2500), value: -20.0, curve: Curves.easeInOutSine),
        Keyframe(time: _defaultDuration, value: 0.0, curve: Curves.easeInOutSine),
      ],
    );
  }

  static Timeline isometricSlide() {
    return Timeline(
      duration: _defaultDuration,
      rotation: [
        const Keyframe(time: Duration.zero, value: -0.261), // ~ -15 degrees
        Keyframe(time: _defaultDuration, value: -0.261),
      ],
      scale: [
        const Keyframe(time: Duration.zero, value: 0.8),
        Keyframe(time: _defaultDuration, value: 0.85),
      ],
      positionY: [
        const Keyframe(time: Duration.zero, value: 100.0),
        Keyframe(time: _defaultDuration, value: -100.0),
      ],
    );
  }

  static Timeline whipPan() {
    return Timeline(
      duration: _defaultDuration,
      positionX: [
        const Keyframe(time: Duration.zero, value: 800.0),
        const Keyframe(time: Duration(milliseconds: 600), value: -20.0, curve: Curves.easeOutExpo),
        const Keyframe(time: Duration(milliseconds: 1000), value: 0.0, curve: Curves.easeOutSine),
        Keyframe(time: _defaultDuration, value: 0.0),
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
    {'name': 'Slam', 'timeline': slam()},
    {'name': 'Float', 'timeline': float()},
    {'name': 'Iso Slide', 'timeline': isometricSlide()},
    {'name': 'Whip Pan', 'timeline': whipPan()},
  ];
}
