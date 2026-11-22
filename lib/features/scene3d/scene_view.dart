import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/widgets.dart';

import 'bezel_scene_interop.dart';
import 'scene_controller.dart';
import 'scene_pose.dart';

/// Hosts the Three.js view (web/scene/) inside the Flutter layout.
/// Calls [onReady] once with a controller for driving the scene.
class SceneView extends StatefulWidget {
  const SceneView({super.key, required this.onReady});

  final ValueChanged<SceneController> onReady;

  @override
  State<SceneView> createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView> {
  SceneController? _controller;
  bool _disposed = false;

  Future<void> _mount(Object element) async {
    final host = element as JSObject;
    final style = host['style'] as JSObject;
    style['width'] = '100%'.toJS;
    style['height'] = '100%'.toJS;

    if (bezelSceneApi == null) await bezelSceneReady.toDart;
    if (_disposed) return;

    late final SceneController controller;
    void onPose(JSNumber turn, JSNumber tilt) => controller.pose.value =
        ScenePose(turn: turn.toDartDouble, tilt: tilt.toDartDouble);
    controller = SceneController(bezelSceneApi!.mount(host, onPose.toJS));
    _controller = controller;
    widget.onReady(controller);
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(tagName: 'div', onElementCreated: _mount);
  }
}
