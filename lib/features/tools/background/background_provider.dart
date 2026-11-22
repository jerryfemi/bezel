import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import 'scene_backgrounds.dart';

class BackgroundNotifier extends Notifier<SceneBackground> {
  @override
  SceneBackground build() => sceneBackgrounds.first;

  void select(SceneBackground background) {
    state = background;
    apply();
  }

  /// Sends the current background to the 3D view.
  void apply() => ref.read(sceneControllerProvider)?.setBackground(state.hex);
}

final backgroundProvider =
    NotifierProvider<BackgroundNotifier, SceneBackground>(BackgroundNotifier.new);
