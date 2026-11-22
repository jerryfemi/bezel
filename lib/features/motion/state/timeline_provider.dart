import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../scene3d/scene_pose.dart';
import '../model/keyframe.dart';
import '../model/motion_presets.dart';
import '../model/motion_timeline.dart';
import 'selected_keyframe_provider.dart';

/// The clip's keyframes. Every change is sent to the 3D scene's player.
class TimelineNotifier extends Notifier<MotionTimeline> {
  int _nextId = 0;

  @override
  MotionTimeline build() => const MotionTimeline();

  String _id() => 'k${_nextId++}';

  ScenePose get _livePose => ref.read(sceneControllerProvider)?.pose.value ?? const ScenePose();

  /// Appends [preset] after the last keyframe (or starts the clip with it).
  void addPreset(MotionPreset preset) {
    final keys = state.keyframes;
    if (keys.isEmpty) {
      final base = _livePose;
      final added = preset.build(base, 0, _id);
      // Presets that begin with their own pose (Tilt in) start the clip at 0;
      // others start from the device's current pose.
      if (added.first.time <= 0.05) {
        added[0] = added.first.copyWith(time: 0);
        _set(added);
      } else {
        _set([Keyframe(id: _id(), time: 0, pose: base), ...added]);
      }
    } else {
      _set([...keys, ...preset.build(keys.last.pose, keys.last.time, _id)]);
    }
  }

  /// Captures the device's current pose as a keyframe at [time].
  void addKeyframeAt(double time) {
    final key = Keyframe(id: _id(), time: time, pose: _livePose);
    _set([...state.keyframes.where((k) => (k.time - time).abs() > 0.02), key]);
    ref.read(selectedKeyframeProvider.notifier).state = key.id;
  }

  void update(Keyframe next) =>
      _set([for (final k in state.keyframes) k.id == next.id ? next : k]);

  void remove(String id) {
    _set(state.keyframes.where((k) => k.id != id).toList());
    final selected = ref.read(selectedKeyframeProvider.notifier);
    if (selected.state == id) selected.state = null;
  }

  void clear() {
    _set(const []);
    ref.read(selectedKeyframeProvider.notifier).state = null;
  }

  void setLoop(bool loop) {
    state = state.withLoop(loop);
    _push();
  }

  /// Sends the timeline to the 3D view (used when the view mounts).
  void apply() => _push();

  void _set(List<Keyframe> keys) {
    state = state.withKeyframes(keys);
    _push();
  }

  void _push() => ref.read(sceneControllerProvider)?.setTimeline(state.toJson());
}

final timelineProvider =
    NotifierProvider<TimelineNotifier, MotionTimeline>(TimelineNotifier.new);
