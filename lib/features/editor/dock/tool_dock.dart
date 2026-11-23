import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../export/state/export_provider.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';
import 'frame_shape_menu.dart';

/// Bottom-centre dock: one icon per tool (its panel opens above), then the
/// frame shape. Icons only, names in tooltips, so it stays small.
class ToolDock extends ConsumerWidget {
  const ToolDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeToolProvider);
    return FloatingSurface(
      radius: 14,
      padding: const EdgeInsets.all(5),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final tool in EditorTool.values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: IconToolButton(
              icon: tool.icon,
              tooltip: tool.label,
              selected: tool == active,
              onTap: () {
                ref.read(exportSheetOpenProvider.notifier).state = false;
                ref.read(activeToolProvider.notifier).toggle(tool);
              },
            ),
          ),
        Container(
            width: 1, height: 20, color: BezelColors.stroke,
            margin: const EdgeInsets.symmetric(horizontal: 6)),
        const FrameShapeMenu(),
      ]),
    );
  }
}
