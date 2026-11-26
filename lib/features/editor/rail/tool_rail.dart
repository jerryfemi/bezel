import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../export/state/export_provider.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';
import '../state/scene_provider.dart';
import 'rail_button.dart';

/// The left rail: one button per tool (its panel opens beside the rail),
/// then the Move toggle. The video's shape is in the right panel.
class ToolRail extends ConsumerWidget {
  const ToolRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeToolProvider);
    final moving = ref.watch(sceneInteractionModeProvider) == SceneInteractionMode.move;

    void toggleMove() {
      final next = moving ? SceneInteractionMode.rotate : SceneInteractionMode.move;
      ref.read(sceneInteractionModeProvider.notifier).state = next;
      ref.read(sceneControllerProvider)?.setMoveMode(next == SceneInteractionMode.move);
    }

    return FloatingSurface(
      radius: 14,
      padding: const EdgeInsets.all(6),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final tool in EditorTool.values)
          RailButton(
            icon: tool.icon,
            label: tool.label,
            selected: tool == active,
            onTap: () {
              ref.read(exportSheetOpenProvider.notifier).state = false;
              ref.read(activeToolProvider.notifier).toggle(tool);
            },
          ),
        Container(
          height: 1, width: 28, color: BezelColors.stroke,
          margin: const EdgeInsets.symmetric(vertical: 6),
        ),
        IconToolButton(
          icon: BezelIcons.move,
          tooltip: moving ? 'Back to rotate' : 'Move device (or Shift+drag)',
          selected: moving,
          onTap: toggleMove,
        ),
      ]),
    );
  }
}
