import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_metrics.dart';
import 'canvas/canvas_stage.dart';
import 'dock/output_dock.dart';
import 'dock/tool_dock.dart';
import 'dock/tool_panel_host.dart';
import 'state/active_tool_provider.dart';
import 'top_bar/top_bar.dart';

/// Design mode: the scene fills the window; chrome floats around it.
class EditorPage extends ConsumerWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            ref.read(activeToolProvider.notifier).close(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Stack(children: [
            const Positioned.fill(child: RepaintBoundary(child: CanvasStage())),
            const Positioned(
              top: BezelSpace.edge, left: BezelSpace.edge, right: BezelSpace.edge,
              child: TopBar(),
            ),
            const Positioned(left: BezelSpace.edge, bottom: BezelSpace.edge, child: OutputDock()),
            Positioned(
              right: BezelSpace.edge,
              bottom: BezelSpace.edge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [ToolPanelHost(), SizedBox(height: 10), ToolDock()],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
