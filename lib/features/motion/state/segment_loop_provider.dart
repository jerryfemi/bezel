import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import 'timeline_provider.dart';

/// The move being looped on its own, by its end keyframe's id.
/// While set, playback repeats only that move so edits can be watched live.
class SegmentLoopNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  /// Starts looping the move that ends at keyframe [endKeyId].
  void loop(String endKeyId) {
    state = endKeyId;
    final scene = ref.read(sceneControllerProvider);
    final range = _range();
    if (scene == null || range == null) return;
    scene.setLoopRange(range.$1, range.$2);
    scene.seek(range.$1);
    scene.play();
  }

  /// Back to playing the whole clip.
  void stop() {
    state = null;
    ref.read(sceneControllerProvider)?.setLoopRange(null, null);
  }

  /// Keeps the loop's bounds in step after keyframes are edited or moved.
  void sync() {
    if (state == null) return;
    final range = _range();
    if (range == null) return stop();
    ref.read(sceneControllerProvider)?.setLoopRange(range.$1, range.$2);
  }

  (double, double)? _range() {
    final keys = ref.read(timelineProvider).keyframes;
    final i = keys.indexWhere((k) => k.id == state);
    if (i < 1) return null;
    return (keys[i - 1].time, keys[i].time);
  }
}

final segmentLoopProvider =
    NotifierProvider<SegmentLoopNotifier, String?>(SegmentLoopNotifier.new);
