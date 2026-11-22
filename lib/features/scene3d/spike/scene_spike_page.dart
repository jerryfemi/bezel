import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../device_catalog.dart';
import '../device_profile.dart';
import '../scene_controller.dart';
import '../scene_pose.dart';
import '../scene_view.dart';
import 'spike_toolbar.dart';

/// Phase 2 test bench: one real 3D device you can drag, recolour and put
/// media on. Open the app with `?scene=3d` to see it.
class SceneSpikePage extends StatefulWidget {
  const SceneSpikePage({super.key});

  @override
  State<SceneSpikePage> createState() => _SceneSpikePageState();
}

class _SceneSpikePageState extends State<SceneSpikePage> {
  SceneController? _scene;
  DeviceProfile? _profile;
  DeviceEntry _device = deviceCatalog.first;
  String? _finishId;
  String? _error;

  Future<void> _onReady(SceneController scene) async {
    _scene = scene;
    await _load(_device);
  }

  Future<void> _load(DeviceEntry device) async {
    final scene = _scene;
    if (scene == null) return;
    setState(() { _device = device; _error = null; });
    try {
      final profile = await scene.loadDevice(device.baseUrl);
      scene.setPose(const ScenePose(turn: -20, tilt: 6));
      setState(() { _profile = profile; _finishId = profile.defaultFinish; });
    } catch (e) {
      setState(() => _error = 'Could not load ${device.label}: $e');
    }
  }

  void _pickFinish(String id) {
    _scene?.setFinish(id);
    setState(() => _finishId = id);
  }

  Future<void> _pickMedia({required bool video}) async {
    final picker = ImagePicker();
    final file = video
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    video ? await _scene?.setScreenVideo(file.path) : await _scene?.setScreenImage(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E11),
      body: Stack(
        children: [
          Positioned.fill(child: SceneView(onReady: _onReady)),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SpikeToolbar(
              device: _device,
              profile: _profile,
              finishId: _finishId,
              pose: _scene?.pose,
              error: _error,
              onDevice: _load,
              onFinish: _pickFinish,
              onImage: () => _pickMedia(video: false),
              onVideo: () => _pickMedia(video: true),
            ),
          ),
        ],
      ),
    );
  }
}
