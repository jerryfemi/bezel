import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'bezel_scene_interop.dart';
import 'device_profile.dart';
import 'scene_pose.dart';
import 'scene_specs.dart';

/// Dart-side handle to one mounted 3D view. Created by `SceneView`.
class SceneController {
  SceneController(this._handle) {
    void bounds(JSString? json) {
      if (json == null) {
        captionBounds.value = null;
        return;
      }
      final b = jsonDecode(json.toDart) as Map<String, dynamic>;
      Rect? rect(Object? r) {
        if (r is! Map) return null;
        double n(String k) => (r[k] as num).toDouble();
        return Rect.fromLTWH(n('x'), n('y'), n('w'), n('h'));
      }
      captionBounds.value = (head: rect(b['head']), sub: rect(b['sub']));
    }
    _handle.onCaptionBounds(bounds.toJS);
    _handle.onScreenTap((() => onScreenTap?.call()).toJS);
  }

  final SceneHandle _handle;

  /// Updated as the user drags the device, and when [setPose] is called.
  final pose = ValueNotifier(const ScenePose());

  /// Playback position in seconds, and whether the clip is playing.
  final time = ValueNotifier(0.0);
  final playing = ValueNotifier(false);

  /// Where the headline and subtitle sit, as fractions of the frame; null when
  /// the caption is off.
  /// Called when the user clicks the phone's screen.
  void Function()? onScreenTap;

  final captionBounds = ValueNotifier<({Rect? head, Rect? sub})?>(null);

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

  /// Loops only [start]..[end] seconds; null plays the whole clip.
  void setLoopRange(double? start, double? end) => _handle.setLoopRange(start ?? -1, end ?? -1);

  void play() => _handle.play();

  void pause() => _handle.pause();

  void seek(double seconds) => _handle.seek(seconds);

  /// Renders and downloads the clip. Returns the file name, or null if cancelled.
  Future<String?> exportClip(String settingsJson, void Function(int frame, int total) onProgress) async {
    void progress(JSNumber frame, JSNumber total) => onProgress(frame.toDartInt, total.toDartInt);
    final result = await _handle.exportClip(settingsJson, progress.toJS).toDart;
    final decoded = jsonDecode(result.toDart);
    return decoded == null ? null : (decoded as Map<String, dynamic>)['filename'] as String;
  }

  void cancelExport() => _handle.cancelExport();

  /// A small JPEG data URL of the current frame, or null mid-export.
  String? snapshot({int width = 320}) => _handle.snapshot(width)?.toDart;

  void dispose() {
    _handle.dispose();
    pose.dispose();
    time.dispose();
    playing.dispose();
    captionBounds.dispose();
  }
}
