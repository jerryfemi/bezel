import 'package:flutter/material.dart';

import '../../app/theme/bezel_metrics.dart';
import 'dock/output_dock.dart';
import 'dock/tool_dock.dart';
import 'dock/tool_panel_host.dart';

/// Design mode chrome: output dock bottom-left, tool dock and its panel
/// bottom-right. The canvas keeps everything else.
class DesignLayout extends StatelessWidget {
  const DesignLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [
      Positioned(left: BezelSpace.edge, bottom: BezelSpace.edge, child: OutputDock()),
      Positioned(
        right: BezelSpace.edge,
        bottom: BezelSpace.edge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [ToolPanelHost(), SizedBox(height: 10), ToolDock()],
        ),
      ),
    ]);
  }
}
