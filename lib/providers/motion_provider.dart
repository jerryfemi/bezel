import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/motion/scene_state.dart';
import '../models/motion/motion_sequence.dart';

import 'mockup_provider.dart';

// Provides the current time in the motion timeline
final currentPlaybackTimeProvider = StateProvider<Duration>(
  (ref) => Duration.zero,
);

// The active motion sequence
final activeSequenceProvider = StateProvider<MotionSequence>((ref) {
  return const MotionSequence(blocks: []);
});

// The currently selected block index for editing in the inspector
final activeBlockIndexProvider = StateProvider<int>((ref) => 0);

// Evaluates the current scene state based on the sequence and current time.
final animatedSceneStateProvider = Provider<SceneState>((ref) {
  final sequence = ref.watch(activeSequenceProvider);
  final currentTime = ref.watch(currentPlaybackTimeProvider);
  final project = ref.watch(mockupProjectProvider);

  // Define the base state from the static editor values
  final baseState = SceneState(
    positionX: 0.0,
    positionY: 0.0,
    scale: 1.0,
    rotation: project.rotationZ,
    opacity: 1.0,
  );

  return sequence.evaluateAt(currentTime, baseState: baseState);
});
