import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import 'bezel_scene_interop.dart';
import 'device_profile.dart';
import 'scene_pose.dart';

/// Dart-side handle to one mounted 3D view. Created by `SceneView`.
class SceneController {
  SceneController(this._handle);

  final SceneHandle _handle;

  /// Updated as the user drags the device, and when [setPose] is called.
  final pose = ValueNotifier(const ScenePose());

  Future<DeviceProfile> loadDevice(String baseUrl, {String? finishId}) async {
    final json = await _handle.loadDevice(baseUrl, finishId).toDart;
    return DeviceProfile.fromJson(jsonDecode(json.toDart) as Map<String, dynamic>);
  }

  void setFinish(String finishId) => _handle.setFinish(finishId);

  Future<void> setScreenImage(String url) => _handle.setScreenImage(url).toDart;

  Future<void> setScreenVideo(String url) => _handle.setScreenVideo(url).toDart;

  void setPose(ScenePose next) => _handle.setPose(next.turn, next.tilt);

  void setBackground(String hex) => _handle.setBackground(hex);

  void dispose() {
    _handle.dispose();
    pose.dispose();
  }
}
