import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import 'bezel_scene_interop.dart';
import 'device_profile.dart';
import 'scene_pose.dart';
import 'scene_specs.dart';

/// Dart-side handle to one mounted 3D view. Created by `SceneView`.
class SceneController {
  SceneController(this._handle);

  final SceneHandle _handle;

  /// Updated as the user drags the device, and when [setPose] is called.
  final pose = ValueNotifier(const ScenePose());

  /// Playback position in seconds, and whether the clip is playing.
  final time = ValueNotifier(0.0);
  final playing = ValueNotifier(false);

  Future<DeviceProfile> loadDevice(String baseUrl, {String? finishId}) async {
    final json = await _handle.loadDevice(baseUrl, finishId).toDart;
    return DeviceProfile.fromJson(jsonDecode(json.toDart) as Map<String, dynamic>);
  }

  void setFinish(String finishId) => _handle.setFinish(finishId);

  Future<void> setScreenImage(String url) => _handle.setScreenImage(url).toDart;

  Future<void> setScreenVideo(String url) => _handle.setScreenVideo(url).toDart;

  void setPose(ScenePose next) => _handle.setPose(next.turn, next.tilt, next.zoom);

  Future<void> setBackground(BackgroundSpec spec) => _handle.setBackground(spec.toJson()).toDart;

  void setCaption(CaptionSpec spec) => _handle.setCaption(spec.toJson());

  void setLight(LightSpec spec) => _handle.setLight(spec.toJson());

  void setTimeline(String json) => _handle.setTimeline(json);

  void play() => _handle.play();

  void pause() => _handle.pause();

  void seek(double seconds) => _handle.seek(seconds);

  void dispose() {
    _handle.dispose();
    pose.dispose();
    time.dispose();
    playing.dispose();
  }
}
