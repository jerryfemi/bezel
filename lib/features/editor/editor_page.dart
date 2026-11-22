import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_metrics.dart';
import '../export/state/export_provider.dart';
import 'canvas/canvas_stage.dart';
import 'design_layout.dart';
import 'motion_layout.dart';
import 'state/active_tool_provider.dart';
import 'state/editor_mode_provider.dart';
import 'top_bar/top_bar.dart';

/// The editor: the scene fills the window; each mode floats its own chrome
/// around it. The 3D view is never rebuilt when switching modes.
class EditorPage extends ConsumerWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(editorModeProvider);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          ref.read(activeToolProvider.notifier).close();
          ref.read(exportSheetOpenProvider.notifier).state = false;
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Stack(children: [
            const Positioned.fill(child: RepaintBoundary(child: CanvasStage())),
            Positioned.fill(
              child: mode == EditorMode.design ? const DesignLayout() : const MotionLayout(),
            ),
            const Positioned(
              top: BezelSpace.edge, left: BezelSpace.edge, right: BezelSpace.edge,
              child: TopBar(),
            ),
          ]),
        ),
      ),
    );
  }
}
