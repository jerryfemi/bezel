import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_metrics.dart';
import '../../app/theme/bezel_motion.dart';
import '../export/state/export_provider.dart';
import '../export/widgets/export_sheet.dart';
import 'dock/output_dock.dart';
import 'dock/tool_dock.dart';
import 'dock/tool_panel_host.dart';

/// Design mode chrome: output dock (and the export sheet above it)
/// bottom-left; tool dock and its panel bottom-right.
class DesignLayout extends ConsumerWidget {
  const DesignLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportOpen = ref.watch(exportSheetOpenProvider);
    return Stack(children: [
      Positioned(
        left: BezelSpace.edge,
        bottom: BezelSpace.edge,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedSwitcher(
            duration: BezelMotion.of(context, BezelMotion.panel),
            switchInCurve: BezelMotion.settle,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween(begin: 0.94, end: 1.0).animate(animation),
                alignment: Alignment.bottomLeft,
                child: child,
              ),
            ),
            child: exportOpen ? const ExportSheet() : const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          const OutputDock(),
        ]),
      ),
      const Positioned(
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
