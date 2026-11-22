import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scene3d/scene_controller.dart';

/// The live 3D view, once it has mounted. Null until then.
final sceneControllerProvider = StateProvider<SceneController?>((ref) => null);
