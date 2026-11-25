import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../timeline/widgets/timeline_editor.dart';
import '../motion_layout.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_mode_provider.dart';
import 'dot_grid_painter.dart';
import 'scene_frame.dart';

/// Fills the window behind the floating chrome. Clicking the empty canvas
/// closes any open tool panel.
class CanvasStage extends ConsumerWidget {
  const CanvasStage({super.key});

  /// Room kept clear for each mode's chrome.
  static const _design = EdgeInsets.fromLTRB(24, 76, 24, 100);
  static final _motion = EdgeInsets.fromLTRB(
    MotionLayout.presetsWidth + 28, 76, MotionLayout.inspectorWidth + 28, TimelineEditor.height + 34);

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
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: ref.watch(editorModeProvider) == EditorMode.design ? _design : _motion,
            child: const SceneFrame(),
          ),
        ),
      ),
    );
  }
}
