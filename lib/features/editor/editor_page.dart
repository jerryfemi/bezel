import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_metrics.dart';
import '../../core/widgets/pointer_shield.dart';
import '../export/state/export_provider.dart';
import '../projects/state/projects_provider.dart';
import '../projects/widgets/projects_menu.dart';
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
    final projectsOpen = ref.watch(projectsMenuOpenProvider);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          ref.read(activeToolProvider.notifier).close();
          ref.read(exportSheetOpenProvider.notifier).state = false;
          ref.read(projectsMenuOpenProvider.notifier).state = false;
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
            if (projectsOpen) ...[
              // Clicking anywhere else closes the menu (and never turns the phone).
              Positioned.fill(
                top: BezelSpace.edge + 52,
                child: PointerShield(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref.read(projectsMenuOpenProvider.notifier).state = false,
                  ),
                ),
              ),
              const Positioned(
                top: BezelSpace.edge + 52,
                left: BezelSpace.edge,
                child: ProjectsMenu(),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
