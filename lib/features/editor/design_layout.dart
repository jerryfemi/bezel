import 'package:flutter/material.dart';

import '../../app/theme/bezel_metrics.dart';
import 'dock/tool_dock.dart';
import 'dock/tool_panel_host.dart';

/// Design mode chrome: the tool dock bottom-centre with its panel above it.
class DesignLayout extends StatelessWidget {
  const DesignLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [
      Positioned(
        left: 0,
        right: 0,
        bottom: BezelSpace.edge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [ToolPanelHost(), SizedBox(height: 10), ToolDock()],
        ),
      ),
    ]);
  }
}
