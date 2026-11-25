// Dart bindings for window.BezelScene (web/scene/bezel_scene.js).
import 'dart:js_interop';

@JS('BezelScene')
external BezelSceneApi? get bezelSceneApi;

/// Resolves once web/scene/bezel_scene.js has loaded (see web/index.html).
@JS('bezelSceneReady')
external JSPromise<JSAny?> get bezelSceneReady;

extension type BezelSceneApi._(JSObject _) implements JSObject {
  external SceneHandle mount(
      JSObject host, JSFunction onPose, JSFunction onTime, JSFunction onPosition);
}

extension type SceneHandle._(JSObject _) implements JSObject {
  external JSPromise<JSString> loadDevice(String baseUrl, String? finishId);
  external void setFinish(String finishId);
  external void addAsset(String id, String url, String kind);
  external void removeAsset(String id);
  external JSPromise<JSString> probeAsset(String id);
  external JSPromise<JSString> filmstrip(String id, int count, int height);
  external JSPromise<JSString> peaks(String id, int count);
  external JSPromise<PickedFile?> pickFile(String accept);
  external void setTracks(String json);
  external void setCaptionEditing(String? id, String? part);
  external void setPose(num turn, num tilt, num zoom);
  external void setPosition(num x, num y);
  external void setMoveMode(bool enabled);
  external JSPromise<JSAny?> setBackground(String json);
  external void onCaptionBounds(JSFunction fn);
  external void onScreenTap(JSFunction fn);
  external JSString? snapshot(num width);
  external void setLight(String json);
  external void setTimeline(String json);
  external void setLoopRange(num start, num end);
  external void play();
  external void pause();
  external void seek(num seconds);
  external JSPromise<JSString> exportClip(String json, JSFunction onProgress);
  external void cancelExport();
  external void dispose();
}

/// A file chosen in the browser's picker (web/scene/pick_file.js).
extension type PickedFile._(JSObject _) implements JSObject {
  external String get name;
  external String get type;
  external JSUint8Array get bytes;
}
