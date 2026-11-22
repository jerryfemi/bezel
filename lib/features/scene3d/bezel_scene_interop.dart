// Dart bindings for window.BezelScene (web/scene/bezel_scene.js).
import 'dart:js_interop';

@JS('BezelScene')
external BezelSceneApi? get bezelSceneApi;

/// Resolves once web/scene/bezel_scene.js has loaded (see web/index.html).
@JS('bezelSceneReady')
external JSPromise<JSAny?> get bezelSceneReady;

extension type BezelSceneApi._(JSObject _) implements JSObject {
  external SceneHandle mount(JSObject host, JSFunction onPose);
}

extension type SceneHandle._(JSObject _) implements JSObject {
  external JSPromise<JSString> loadDevice(String baseUrl, String? finishId);
  external void setFinish(String finishId);
  external JSPromise<JSAny?> setScreenImage(String url);
  external JSPromise<JSAny?> setScreenVideo(String url);
  external void setPose(num turn, num tilt);
  external void setBackground(String hex);
  external void dispose();
}
