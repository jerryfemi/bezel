import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_metrics.dart';
import '../export/state/export_provider.dart';
import '../projects/state/projects_provider.dart';
import '../projects/widgets/projects_sidebar.dart';
import 'canvas/canvas_stage.dart';
import 'design_layout.dart';
import 'motion_layout.dart';
import 'state/active_tool_provider.dart';
import 'state/editor_mode_provider.dart';
import 'chrome/corner_bar.dart';
import 'chrome/export_popover.dart';
import 'chrome/sidebar_pill.dart';

/// The editor: the scene fills the window; each mode floats its own chrome
/// around it. The 3D view is never rebuilt when switching modes.
class EditorPage extends ConsumerWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(editorModeProvider);
    final projectsOpen = ref.watch(projectsMenuOpenProvider);
    void toggleSidebar() =>
        ref.read(projectsMenuOpenProvider.notifier).state = !projectsOpen;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          ref.read(activeToolProvider.notifier).close();
          ref.read(exportSheetOpenProvider.notifier).state = false;
        },
        const SingleActivator(LogicalKeyboardKey.backslash, control: true): toggleSidebar,
        const SingleActivator(LogicalKeyboardKey.backslash, meta: true): toggleSidebar,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(children: [
            // Docked, so the canvas makes room for it instead of being covered.
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: projectsOpen ? ProjectsSidebar.width : 0,
              child: const ClipRect(
                child: OverflowBox(
                  alignment: Alignment.centerRight,
                  minWidth: ProjectsSidebar.width,
                  maxWidth: ProjectsSidebar.width,
                  child: ProjectsSidebar(),
                ),
              ),
            ),
            Expanded(
              child: Stack(children: [
                const Positioned.fill(child: RepaintBoundary(child: CanvasStage())),
                Positioned.fill(
                  child: mode == EditorMode.design ? const DesignLayout() : const MotionLayout(),
                ),
                if (!projectsOpen)
                  const Positioned(top: BezelSpace.edge, left: BezelSpace.edge, child: SidebarPill()),
                const Positioned(top: BezelSpace.edge, right: BezelSpace.edge, child: CornerBar()),
                const Positioned(
                  top: BezelSpace.edge + 52, right: BezelSpace.edge, child: ExportPopover()),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
