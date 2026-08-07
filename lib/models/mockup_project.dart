import 'package:flutter/material.dart';
import 'device_spec.dart';

class MockupProject {
  final DeviceSpec device;
  final String? sourceImagePath;
  final bool isVideo;
  
  // Rotation values in radians
  final double rotationX;
  final double rotationY;
  final double rotationZ;

  // Background settings
  final Color backgroundColor;

  // Export flag: when true, the media widget renders transparent so we can capture just the bezel
  final bool isCapturingOverlay;

  const MockupProject({
    required this.device,
    this.sourceImagePath,
    this.isVideo = false,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.isCapturingOverlay = false,
  });

  MockupProject copyWith({
    DeviceSpec? device,
    String? sourceImagePath,
    bool? isVideo,
    double? rotationX,
    double? rotationY,
    double? rotationZ,
    Color? backgroundColor,
    bool? isCapturingOverlay,
  }) {
    return MockupProject(
      device: device ?? this.device,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      isVideo: isVideo ?? this.isVideo,
      rotationX: rotationX ?? this.rotationX,
      rotationY: rotationY ?? this.rotationY,
      rotationZ: rotationZ ?? this.rotationZ,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isCapturingOverlay: isCapturingOverlay ?? this.isCapturingOverlay,
    );
  }
}

