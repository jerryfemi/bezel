import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_metrics.dart';
import '../export/state/export_provider.dart';
import '../timeline/widgets/timeline_shortcuts.dart';
import 'canvas/canvas_stage.dart';
import 'chrome/corner_bar.dart';
import 'chrome/export_popover.dart';
import 'chrome/project_pill.dart';
import 'editor_chrome.dart';
import 'state/active_tool_provider.dart';

/// The editor, canvas first: the frame sits in the middle, the tools rail
/// and its panel on the left, the selection's settings on the right, and the
/// timeline docked along the bottom. The 3D view is never rebuilt.
class EditorPage extends ConsumerWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          ref.read(activeToolProvider.notifier).close();
          ref.read(exportSheetOpenProvider.notifier).state = false;
        },
      },
      child: Focus(
        autofocus: true,
        child: TimelineShortcuts(
          child: Scaffold(
            body: Stack(children: const [
              Positioned.fill(child: RepaintBoundary(child: CanvasStage())),
              Positioned.fill(child: EditorChrome()),
              Positioned(top: BezelSpace.edge, left: BezelSpace.edge, child: ProjectPill()),
              Positioned(top: BezelSpace.edge, right: BezelSpace.edge, child: CornerBar()),
              Positioned(top: BezelSpace.edge + 48, right: BezelSpace.edge, child: ExportPopover()),
            ]),
          ),
        ),
      ),
    );
  }
}
