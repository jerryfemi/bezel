import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scene3d/scene_controller.dart';
import '../../scene3d/scene_pose.dart';
import '../../tools/background/background_provider.dart';
import '../../tools/device/device_selection.dart';
import 'scene_provider.dart';

/// The default hero angle a fresh project opens at.
const heroPose = ScenePose(turn: -20, tilt: 6);

/// Runs once when the 3D view mounts: loads the device and applies settings.
Future<void> attachScene(WidgetRef ref, SceneController scene) async {
  ref.read(sceneControllerProvider.notifier).state = scene;
  ref.read(backgroundProvider.notifier).apply();
  final device = ref.read(deviceSelectionProvider).entry;
  await ref.read(deviceSelectionProvider.notifier).select(device);
  scene.setPose(heroPose);
}
