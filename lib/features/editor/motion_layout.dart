import 'package:flutter/material.dart';

import '../../app/theme/bezel_metrics.dart';
import '../motion/widgets/preset_list_panel.dart';
import '../timeline/widgets/clip_inspector.dart';
import '../timeline/widgets/timeline_editor.dart';

/// Timeline mode: motion presets on the left, the selected clip's settings on
/// the right, and the multi-track timeline across the bottom.
class MotionLayout extends StatelessWidget {
  const MotionLayout({super.key});

  static const sideTop = 72.0;
  static const presetsWidth = 240.0;
  static const inspectorWidth = 300.0;

  @override
  Widget build(BuildContext context) {
    final sideBottom = TimelineEditor.height + BezelSpace.edge + 10;
    return Stack(children: [
      Positioned(
        left: BezelSpace.edge, top: sideTop, bottom: sideBottom, width: presetsWidth,
        child: const PresetListPanel(),
      ),
      Positioned(
        right: BezelSpace.edge, top: sideTop, bottom: sideBottom, width: inspectorWidth,
        child: const ClipInspector(),
      ),
      const Positioned(
        left: BezelSpace.edge, right: BezelSpace.edge, bottom: BezelSpace.edge,
        child: TimelineEditor(),
      ),
    ]);
  }
}
