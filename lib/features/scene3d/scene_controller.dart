import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'bezel_scene_interop.dart';
import 'device_profile.dart';
import 'scene_position.dart';
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

      captionBounds.value = (
        id: b['id'] as String?,
        head: rect(b['head']),
        sub: rect(b['sub']),
      );
    }

    _handle.onCaptionBounds(bounds.toJS);
    _handle.onScreenTap((() => onScreenTap?.call()).toJS);
  }

  final SceneHandle _handle;

  /// Updated as the user drags the device, and when [setPose] is called.
  final pose = ValueNotifier(const ScenePose());

  /// User placement on the artboard, independent of rotation and zoom.
  final position = ValueNotifier(const ScenePosition());

  /// Playback position in seconds, and whether the clip is playing.
  final time = ValueNotifier(0.0);
  final playing = ValueNotifier(false);

  /// Called when the user clicks the phone's empty screen.
  void Function()? onScreenTap;

  /// The caption on screen right now: its clip id and where its headline and
  /// subtitle sit, as fractions of the frame. Null when no caption shows.
  final captionBounds = ValueNotifier<({String? id, Rect? head, Rect? sub})?>(
    null,
  );

  Future<DeviceProfile> loadDevice(String baseUrl, {String? finishId}) async {
    final json = await _handle.loadDevice(baseUrl, finishId).toDart;
    return DeviceProfile.fromJson(
      jsonDecode(json.toDart) as Map<String, dynamic>,
    );
  }

  void setFinish(String finishId) => _handle.setFinish(finishId);

  /// Registers a media file with the scene; [kind] is image, video or audio.
  void addAsset(String id, String url, String kind) =>
      _handle.addAsset(id, url, kind);

  void removeAsset(String id) => _handle.removeAsset(id);

  /// The file's length in seconds (0 for images).
  Future<double> probeDuration(String id) async {
    final json = await _handle.probeAsset(id).toDart;
    return ((jsonDecode(json.toDart) as Map)['duration'] as num).toDouble();
  }

  /// Small frame thumbnails (data URLs) across a video, or the image itself.
  Future<List<String>> filmstrip(
    String id, {
    int count = 8,
    int height = 48,
  }) async {
    final json = await _handle.filmstrip(id, count, height).toDart;
    return [for (final s in jsonDecode(json.toDart) as List) s as String];
  }

  /// Loudness from 0 to 1 across the file.
  Future<List<double>> peaks(String id, {int count = 400}) async {
    final json = await _handle.peaks(id, count).toDart;
    return [
      for (final p in jsonDecode(json.toDart) as List) (p as num).toDouble(),
    ];
  }

  /// Opens the file picker (call from a tap). Null if nothing was chosen.
  Future<({String name, String type, Uint8List bytes})?> pickFile(
    String accept,
  ) async {
    final file = await _handle.pickFile(accept).toDart;
    if (file == null) return null;
    return (name: file.name, type: file.type, bytes: file.bytes.toDart);
  }

  /// Sends every caption, screen and audio clip (see `Tracks.toJson`).
  void setTracks(String json) => _handle.setTracks(json);

  /// Hides [part] of caption [id] while it is typed on the canvas.
  void setCaptionEditing(String? id, String? part) =>
      _handle.setCaptionEditing(id, part);

  void setPose(ScenePose next) =>
      _handle.setPose(next.turn, next.tilt, next.zoom);

  void setPosition(ScenePosition next) => _handle.setPosition(next.x, next.y);

  void setMoveMode(bool enabled) => _handle.setMoveMode(enabled);

  Future<void> setBackground(BackgroundSpec spec) =>
      _handle.setBackground(spec.toJson()).toDart;

  void setLight(LightSpec spec) => _handle.setLight(spec.toJson());

  void setTimeline(String json) => _handle.setTimeline(json);

  /// Loops only [start]..[end] seconds; null plays the whole clip.
  void setLoopRange(double? start, double? end) =>
      _handle.setLoopRange(start ?? -1, end ?? -1);

  void play() => _handle.play();

  void pause() => _handle.pause();

  void seek(double seconds) => _handle.seek(seconds);

  /// Renders and downloads the clip. Returns the file name, or null if cancelled.
  Future<String?> exportClip(
    String settingsJson,
    void Function(int frame, int total) onProgress,
  ) async {
    void progress(JSNumber frame, JSNumber total) =>
        onProgress(frame.toDartInt, total.toDartInt);
    final result = await _handle.exportClip(settingsJson, progress.toJS).toDart;
    final decoded = jsonDecode(result.toDart);
    return decoded == null
        ? null
        : (decoded as Map<String, dynamic>)['filename'] as String;
  }

  void cancelExport() => _handle.cancelExport();

  /// A small JPEG data URL of the current frame, or null mid-export.
  String? snapshot({int width = 320}) => _handle.snapshot(width)?.toDart;

  void dispose() {
    _handle.dispose();
    pose.dispose();
    position.dispose();
    time.dispose();
    playing.dispose();
    captionBounds.dispose();
  }
}
