import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/device_spec.dart';
import '../models/mockup_project.dart';

class MockupProjectNotifier extends Notifier<MockupProject> {
  @override
  MockupProject build() {
    return const MockupProject(
      device: DeviceSpecConstants.placeholderIPhone,
    );
  }

  void setDevice(DeviceSpec device) {
    state = state.copyWith(device: device);
  }

  void setSourceImage(String path, {bool isVideo = false}) {
    state = state.copyWith(sourceImagePath: path, isVideo: isVideo);
  }

  void setRotation(double x, double y, double z) {
    state = state.copyWith(rotationX: x, rotationY: y, rotationZ: z);
  }

  void updateRotation(double dx, double dy, double dz) {
     state = state.copyWith(
       rotationX: state.rotationX + dx,
       rotationY: state.rotationY + dy,
       rotationZ: state.rotationZ + dz,
     );
  }

  void setBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color);
  }

  void setCapturingOverlay(bool capturing) {
    state = state.copyWith(isCapturingOverlay: capturing);
  }

  void setMediaTransform(Matrix4 transform) {
    state = state.copyWith(mediaTransform: transform);
  }
}

final mockupProjectProvider = NotifierProvider<MockupProjectNotifier, MockupProject>(() {
  return MockupProjectNotifier();
});

final videoControllerProvider = StateProvider<VideoPlayerController?>((ref) => null);

/// Stores the raw bytes of the uploaded video file for FFmpeg compositing.
final videoRawBytesProvider = StateProvider<Uint8List?>((ref) => null);

enum EditorTool {
  device,
  background,
  crop,
  export,
}

final activeEditorToolProvider = StateProvider<EditorTool>((ref) => EditorTool.device);
