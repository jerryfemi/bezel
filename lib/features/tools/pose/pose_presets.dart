import '../../scene3d/scene_pose.dart';

/// Named starting angles. Picking one turns the device; it can still be dragged.
class PosePreset {
  const PosePreset(this.name, this.pose);

  final String name;
  final ScenePose pose;
}

const posePresets = [
  PosePreset('Front', ScenePose()),
  PosePreset('Hero', ScenePose(turn: -20, tilt: 6)),
  PosePreset('Lean', ScenePose(turn: 28, tilt: 10)),
  PosePreset('Lying', ScenePose(turn: -10, tilt: 55)),
  PosePreset('Side', ScenePose(turn: -72)),
  PosePreset('Low angle', ScenePose(turn: -14, tilt: -20)),
];
