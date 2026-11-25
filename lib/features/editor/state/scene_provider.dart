import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scene3d/scene_controller.dart';

enum SceneInteractionMode { rotate, move }

/// The live 3D view, once it has mounted. Null until then.
final sceneControllerProvider = StateProvider<SceneController?>((ref) => null);

/// Canvas drag behavior. Rotate is the default; Move repositions the device.
final sceneInteractionModeProvider =
    StateProvider<SceneInteractionMode>((ref) => SceneInteractionMode.rotate);
