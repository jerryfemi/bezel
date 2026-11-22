import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scene3d/scene_controller.dart';
import '../../scene3d/scene_pose.dart';
import '../../motion/state/timeline_provider.dart';
import '../../tools/background/background_provider.dart';
import '../../tools/device/device_selection.dart';
import '../../tools/light/light_provider.dart';
import '../../tools/text/caption_provider.dart';
import 'scene_provider.dart';

/// The default hero angle a fresh project opens at.
/// The pose a new project opens in: straight on.
const startPose = ScenePose();

/// Runs once when the 3D view mounts: loads the device and applies settings.
Future<void> attachScene(WidgetRef ref, SceneController scene) async {
  ref.read(sceneControllerProvider.notifier).state = scene;
  ref.read(backgroundProvider.notifier).apply();
  ref.read(captionProvider.notifier).apply();
  ref.read(lightProvider.notifier).apply();
  final device = ref.read(deviceSelectionProvider).entry;
  await ref.read(deviceSelectionProvider.notifier).select(device);
  scene.setPose(startPose);
  ref.read(timelineProvider.notifier).apply();
}
