import 'package:flutter/material.dart';

import '../../app/theme/bezel_metrics.dart';
import '../motion/widgets/keyframe_inspector.dart';
import '../motion/widgets/preset_list_panel.dart';
import '../motion/widgets/timeline_panel.dart';

/// Motion mode chrome: presets left, keyframe inspector right, timeline below.
/// Everything stays visible because timing needs all three at once.
class MotionLayout extends StatelessWidget {
  const MotionLayout({super.key});

  static const sideTop = 72.0;
  static const presetsWidth = 240.0;
  static const inspectorWidth = 290.0;
  static const _sideBottom = TimelinePanel.height + BezelSpace.edge + 10;

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [
      Positioned(
        left: BezelSpace.edge, top: sideTop, bottom: _sideBottom, width: presetsWidth,
        child: PresetListPanel(),
      ),
      Positioned(
        right: BezelSpace.edge, top: sideTop, bottom: _sideBottom, width: inspectorWidth,
        child: KeyframeInspector(),
      ),
      Positioned(
        left: BezelSpace.edge, right: BezelSpace.edge, bottom: BezelSpace.edge,
        child: TimelinePanel(),
      ),
    ]);
  }
}
