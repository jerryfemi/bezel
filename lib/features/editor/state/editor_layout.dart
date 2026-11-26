import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_metrics.dart';
import '../../motion/state/selected_keyframe_provider.dart';
import '../../timeline/state/playhead_provider.dart';
import '../../timeline/state/tracks_provider.dart';
import '../../timeline/widgets/timeline_editor.dart';
import 'active_tool_provider.dart';

/// Sizes of the editor's fixed pieces around the canvas.
abstract final class EditorLayout {
  static const top = 64.0; // below the top pills
  static const rail = 60.0;
  static const flyout = 280.0;
  static const inspector = 292.0;
  static const gap = 8.0;
}

/// Whether a clip or keyframe is selected. The right panel shows its
/// settings then, and the project's settings otherwise.
final hasSelectionProvider = Provider<bool>((ref) {
  if (ref.watch(selectedKeyframeProvider) != null) return true;
  final clip = ref.watch(selectedClipProvider);
  return clip != null && ref.watch(tracksProvider).find(clip) != null;
});

/// The timeline folds down to its toolbar.
final timelineFoldedProvider = StateProvider<bool>((ref) => false);

/// Room the canvas keeps clear of the rail, panels and timeline, so the
/// frame always sits in the open space between them.
final canvasInsetsProvider = Provider<EdgeInsets>((ref) {
  const edge = BezelSpace.edge;
  const breathe = 16.0;
  final flyoutOpen = ref.watch(activeToolProvider) != null;
  final folded = ref.watch(timelineFoldedProvider);
  return EdgeInsets.fromLTRB(
    edge + EditorLayout.rail + (flyoutOpen ? EditorLayout.gap + EditorLayout.flyout : 0) + breathe,
    EditorLayout.top,
    edge + EditorLayout.inspector + breathe,
    edge + TimelineEditor.heightFor(folded: folded) + breathe,
  );
});
