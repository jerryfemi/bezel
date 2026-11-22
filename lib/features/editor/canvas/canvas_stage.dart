import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../state/active_tool_provider.dart';
import 'dot_grid_painter.dart';
import 'scene_frame.dart';

/// Fills the window behind the floating chrome. Clicking the empty canvas
/// closes any open tool panel.
class CanvasStage extends ConsumerWidget {
  const CanvasStage({super.key});

  /// Room kept clear for the top bar and the docks.
  static const _chrome = EdgeInsets.fromLTRB(24, 76, 24, 100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(activeToolProvider.notifier).close(),
      child: const ColoredBox(
        color: BezelColors.canvas,
        child: CustomPaint(
          painter: DotGridPainter(),
          child: Padding(padding: _chrome, child: SceneFrame()),
        ),
      ),
    );
  }
}
