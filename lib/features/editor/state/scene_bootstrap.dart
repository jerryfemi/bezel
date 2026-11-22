import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/state/projects_provider.dart';
import '../../scene3d/scene_controller.dart';
import '../../scene3d/scene_pose.dart';
import 'scene_provider.dart';

/// The pose a new project opens in: straight on.
const startPose = ScenePose();

/// Runs once when the 3D view mounts: opens the last project (or a new one),
/// which loads the device and applies every setting.
Future<void> attachScene(WidgetRef ref, SceneController scene) async {
  ref.read(sceneControllerProvider.notifier).state = scene;
  await ref.read(projectsProvider.notifier).start();
}
