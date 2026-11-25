import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../motion/state/segment_loop_provider.dart';
import '../../motion/state/selected_keyframe_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../tools/media/screen_media_provider.dart';
import '../../tools/text/caption_provider.dart';
import '../model/clips.dart';
import '../model/clip_ops.dart' as ops;
import '../model/tracks.dart';
import 'assets_provider.dart';
import 'edit_history.dart';
import 'playhead_provider.dart';
import 'tracks_provider.dart';

/// The timeline's commands, shared by the toolbar, the track headers and the
/// keyboard shortcuts.
class TimelineActions {
  TimelineActions(this.ref);

  final WidgetRef ref;

  double get _t => ref.read(playheadProvider);

  void select(ClipRef? clip) {
    ref.read(selectedClipProvider.notifier).state = clip;
    if (clip != null) {
      ref.read(selectedKeyframeProvider.notifier).state = null;
      ref.read(segmentLoopProvider.notifier).stop();
    }
  }

  void playPause() {
    final scene = ref.read(sceneControllerProvider);
    if (scene == null) return;
    if (scene.playing.value) return scene.pause();
    ref.read(segmentLoopProvider.notifier).stop();
    scene.play();
  }

  void seek(double t) {
    final scene = ref.read(sceneControllerProvider);
    scene?.pause();
    scene?.seek(t < 0 ? 0 : t);
  }

  /// Cuts the selected clip at the playhead. With nothing selected, cuts
  /// every clip under the playhead (and the move there, with a keyframe).
  void split() {
    final tracks = ref.read(tracksProvider.notifier);
    final selected = ref.read(selectedClipProvider);
    if (selected != null) {
      final right = tracks.split(selected, _t);
      if (right != null) select(right);
      return;
    }
    final state = ref.read(tracksProvider);
    for (final kind in [TrackKind.caption, TrackKind.screen, TrackKind.audio]) {
      for (final c in state.on(kind)) {
        if (ops.canSplit(c, _t)) tracks.split(ClipRef(kind, c.id), _t);
      }
    }
    final motion = ref.read(timelineProvider);
    final scene = ref.read(sceneControllerProvider);
    if (!motion.isEmpty && _t > 0 && _t < motion.duration && scene != null) {
      ref.read(timelineProvider.notifier).splitAt(_t, scene.pose.value);
    }
  }

  /// Deletes the selected clip, or the selected keyframe.
  void delete() {
    final selected = ref.read(selectedClipProvider);
    if (selected != null) {
      ref.read(tracksProvider.notifier).delete(selected);
      select(null);
      return;
    }
    final key = ref.read(selectedKeyframeProvider);
    if (key != null) ref.read(timelineProvider.notifier).remove(key);
  }

  void addCaption() {
    final previous = ref.read(tracksProvider).captions;
    final spec = previous.isEmpty ? CaptionNotifier.defaults : previous.last.spec;
    final clip = ref.read(tracksProvider.notifier).addCaption(spec, at: _t);
    select(ClipRef(TrackKind.caption, clip.id));
  }

  Future<void> addScreen() => ref.read(screenMediaProvider.notifier).addAnother();

  Future<void> addAudio() async {
    final file = await ref.read(sceneControllerProvider)?.pickFile('audio/*,video/*');
    if (file == null) return;
    final asset = await ref
        .read(assetsProvider.notifier)
        .add(name: file.name, mimeType: file.type, bytes: file.bytes);
    final clip = ref.read(tracksProvider.notifier).addAudio(asset, at: _t);
    select(ClipRef(TrackKind.audio, clip.id));
  }

  void addKeyframe() {
    select(null);
    ref.read(timelineProvider.notifier).addKeyframeAt(_t);
  }

  void undo() => ref.read(editHistoryProvider.notifier).undo();
  void redo() => ref.read(editHistoryProvider.notifier).redo();

  /// The finished video's length (0 for a still).
  double get length => clipLength(ref.read(tracksProvider), ref.read(timelineProvider).duration);
}
