import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../projects/state/projects_provider.dart';
import '../../timeline/state/playhead_provider.dart';
import '../../timeline/state/tracks_provider.dart';
import '../../tools/media/screen_media_provider.dart';
import '../../scene3d/scene_controller.dart';
import '../../scene3d/scene_pose.dart';
import 'scene_provider.dart';

/// The pose a new project opens in: straight on.
const startPose = ScenePose();

/// Runs once when the 3D view mounts: opens the last project (or a new one),
/// which loads the device and applies every setting.
Future<void> attachScene(WidgetRef ref, SceneController scene) async {
  ref.read(sceneControllerProvider.notifier).state = scene;
  scene.setMoveMode(
      ref.read(sceneInteractionModeProvider) == SceneInteractionMode.move);
  // Clicking the empty screen is the quickest way to add a screenshot.
  scene.onScreenTap = () {
    if (ref.read(tracksProvider).screens.isEmpty) ref.read(screenMediaProvider.notifier).pick();
  };
  // Providers that depend on the playback position read it from here.
  scene.time.addListener(() => ref.read(playheadProvider.notifier).state = scene.time.value);
  await ref.read(projectsProvider.notifier).start();
}
