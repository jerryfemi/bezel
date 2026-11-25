import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_metrics.dart';
import '../timeline/widgets/timeline_editor.dart';
import 'inspector_host.dart';
import 'rail/flyout_host.dart';
import 'rail/tool_rail.dart';
import 'state/editor_layout.dart';

/// Everything around the canvas: the rail and its panel on the left, the
/// selection's settings on the right, and the timeline docked at the bottom.
class EditorChrome extends ConsumerWidget {
  const EditorChrome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const edge = BezelSpace.edge;
    final folded = ref.watch(timelineFoldedProvider);
    final aboveTimeline = edge + TimelineEditor.heightFor(folded: folded) + EditorLayout.gap;
    return Stack(children: [
      const Positioned(left: edge, top: EditorLayout.top, child: ToolRail()),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        left: edge + EditorLayout.rail + EditorLayout.gap,
        top: EditorLayout.top,
        bottom: aboveTimeline,
        width: EditorLayout.flyout,
        child: const FlyoutHost(),
      ),
      AnimatedPositioned(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        right: edge,
        top: EditorLayout.top,
        bottom: aboveTimeline,
        width: EditorLayout.inspector,
        child: const InspectorHost(),
      ),
      const Positioned(left: edge, right: edge, bottom: edge, child: TimelineEditor()),
    ]);
  }
}
