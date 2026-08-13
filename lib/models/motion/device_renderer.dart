import 'package:flutter/widgets.dart';
import 'scene_state.dart';

abstract class DeviceRenderer {
  const DeviceRenderer();
  
  Widget build(BuildContext context, SceneState scene);
}
