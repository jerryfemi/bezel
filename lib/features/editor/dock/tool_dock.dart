import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/dock_button.dart';
import '../../../core/widgets/floating_surface.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';

/// Bottom-right dock: one button per tool. Each opens its panel above.
class ToolDock extends ConsumerWidget {
  const ToolDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeToolProvider);
    return FloatingSurface(
      padding: const EdgeInsets.all(6),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final tool in EditorTool.values)
          DockButton(
            icon: tool.icon,
            label: tool.label,
            selected: tool == active,
            onTap: () => ref.read(activeToolProvider.notifier).toggle(tool),
          ),
      ]),
    );
  }
}
