import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../scene3d/scene_specs.dart';
import '../../timeline/model/clips.dart';
import '../../timeline/model/tracks.dart';
import '../../timeline/state/playhead_provider.dart';
import '../../timeline/state/tracks_provider.dart';

/// The part of the caption being typed on the canvas, if any.
final captionEditingProvider = StateProvider<CaptionPart?>((ref) => null);

/// The caption clip the Text panel and the canvas edit: the selected caption
/// clip, otherwise the one under the playhead. Null when there is none there.
final captionTargetProvider = Provider<String?>((ref) {
  final captions = ref.watch(tracksProvider.select((t) => t.captions));
  final selected = ref.watch(selectedClipProvider);
  if (selected?.track == TrackKind.caption && captions.any((c) => c.id == selected!.id)) {
    return selected!.id;
  }
  final length = clipLength(ref.watch(tracksProvider), ref.watch(timelineProvider).duration);
  // At the very end of the clip, look just before it, like the preview does.
  final t = ref.watch(playheadProvider).clamp(0.0, length > 0 ? length - 1e-3 : 0.0);
  String? found;
  for (final c in captions) {
    if (c.covers(t)) found = c.id;
  }
  return found;
});

/// The caption being edited, as a [CaptionSpec] ([CaptionSpec.enabled] is
/// false when there is no caption at the playhead). Every setter changes
/// that caption clip on the timeline.
class CaptionNotifier extends Notifier<CaptionSpec> {
  static const defaults = CaptionSpec(
    enabled: true,
    headline: 'Your app, in motion.',
    subtitle: 'Say what it does in one line.',
    side: CaptionSide.left,
  );

  String? get _target => ref.read(captionTargetProvider);

  @override
  CaptionSpec build() {
    final id = ref.watch(captionTargetProvider);
    final editing = ref.watch(captionEditingProvider);
    final captions = ref.watch(tracksProvider.select((t) => t.captions));
    for (final c in captions) {
      if (c.id == id) return c.spec.copyWith(editing: () => editing);
    }
    return defaults.copyWith(enabled: false);
  }

  /// On: adds a caption at the playhead (the first one spans the whole clip)
  /// and selects it. Off: removes the caption being edited.
  void setEnabled(bool on) {
    final tracks = ref.read(tracksProvider.notifier);
    final id = _target;
    if (on && id == null) {
      final previous = ref.read(tracksProvider).captions;
      final spec = previous.isEmpty ? defaults : previous.last.spec.copyWith(enabled: true);
      final clip = tracks.addCaption(spec);
      ref.read(selectedClipProvider.notifier).state = ClipRef(TrackKind.caption, clip.id);
    } else if (!on && id != null) {
      tracks.delete(ClipRef(TrackKind.caption, id));
      ref.read(selectedClipProvider.notifier).state = null;
    }
  }

  void setHeadline(String v) => _change((s) => s.copyWith(headline: v));
  void setSubtitle(String v) => _change((s) => s.copyWith(subtitle: v));
  void setFont(CaptionFont v) => _change((s) => s.copyWith(font: v));
  void setAlign(CaptionAlign v) => _change((s) => s.copyWith(align: v));

  void setSize(CaptionPart part, double v) => _change((s) => part == CaptionPart.headline
      ? s.copyWith(size: v.clamp(0.5, 2.5))
      : s.copyWith(subSize: v.clamp(0.5, 2.5)));

  /// Picks a placement and puts the text back at its layout position.
  void setSide(CaptionSide v) => _change((s) => s.copyWith(
        side: v,
        align: v == CaptionSide.above ? CaptionAlign.center : CaptionAlign.left,
        dx: 0, dy: 0, subDx: 0, subDy: 0,
      ));

  /// Drags a part by a fraction of the frame. Dragging the headline moves the
  /// whole caption; dragging the subtitle pulls it away on its own.
  void moveBy(CaptionPart part, double dx, double dy) => _change((s) => part == CaptionPart.headline
      ? s.copyWith(dx: (s.dx + dx).clamp(-0.8, 0.8), dy: (s.dy + dy).clamp(-0.8, 0.8))
      : s.copyWith(subDx: (s.subDx + dx).clamp(-1.0, 1.0), subDy: (s.subDy + dy).clamp(-1.0, 1.0)));

  void resetPosition() => _change((s) => s.copyWith(dx: 0, dy: 0, subDx: 0, subDy: 0));

  /// Shows a text field over [part] on the canvas (null: done typing).
  void setEditing(CaptionPart? part) {
    ref.read(captionEditingProvider.notifier).state = part;
    ref.read(sceneControllerProvider)?.setCaptionEditing(part == null ? null : _target, part?.name);
  }

  void _change(CaptionSpec Function(CaptionSpec) change) {
    final id = _target;
    if (id != null) ref.read(tracksProvider.notifier).updateCaption(id, change);
  }
}

final captionProvider = NotifierProvider<CaptionNotifier, CaptionSpec>(CaptionNotifier.new);
