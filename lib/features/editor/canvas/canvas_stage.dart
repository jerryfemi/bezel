import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_layout.dart';
import 'dot_grid_painter.dart';
import 'scene_frame.dart';

/// Fills the window behind the chrome. The frame sits in the open space
/// between the panels and slides over as they open and close. Clicking the
/// empty canvas closes the open tool panel.
class CanvasStage extends ConsumerWidget {
  const CanvasStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(activeToolProvider.notifier).close(),
      child: ColoredBox(
        color: BezelColors.canvas,
        child: CustomPaint(
          painter: const DotGridPainter(),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: ref.watch(canvasInsetsProvider),
            child: const SceneFrame(),
          ),
        ),
      ),
    );
  }
}
