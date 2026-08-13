import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/motion/scene_state.dart';
import '../models/motion/timeline.dart';
import 'mockup_provider.dart';

// Provides the current time in the motion timeline
final currentPlaybackTimeProvider = StateProvider<Duration>((ref) => Duration.zero);

// The active timeline (could be a preset, or user-edited)
final activeTimelineProvider = StateProvider<Timeline?>((ref) => null);

// Evaluates the current scene state based on the timeline and current time.
// Also incorporates the static base state from the editor if necessary.
final animatedSceneStateProvider = Provider<SceneState>((ref) {
  final timeline = ref.watch(activeTimelineProvider);
  final currentTime = ref.watch(currentPlaybackTimeProvider);
  final project = ref.watch(mockupProjectProvider);

  // Define the base state from the static editor values
  final baseState = SceneState(
    positionX: 0.0, // Assuming center is 0,0
    positionY: 0.0,
    scale: 1.0,
    rotation: project.rotationZ, // Or map to whatever base static rotation is used
    opacity: 1.0,
  );

  if (timeline == null) {
    return baseState;
  }

  return timeline.evaluateAt(currentTime, baseState: baseState);
});
