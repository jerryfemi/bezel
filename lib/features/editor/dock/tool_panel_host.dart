import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_motion.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../tools/tool_panel_body.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';

/// Shows the open tool's panel above the dock. Panels grow out of the
/// dock's corner and shrink back into it.
class ToolPanelHost extends ConsumerWidget {
  const ToolPanelHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(activeToolProvider);
    return AnimatedSwitcher(
      duration: BezelMotion.of(context, BezelMotion.panel),
      switchInCurve: BezelMotion.settle,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(animation),
          alignment: Alignment.bottomRight,
          child: child,
        ),
      ),
      child: tool == null ? const SizedBox.shrink() : _Panel(key: ValueKey(tool), tool: tool),
    );
  }
}

class _Panel extends ConsumerWidget {
  const _Panel({super.key, required this.tool});

  final EditorTool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340, maxHeight: 540),
      child: FloatingSurface(
        elevated: true,
        radius: BezelRadius.panel,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 6, 2),
            child: Row(children: [
              Text(tool.label, style: BezelType.title),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                onPressed: () => ref.read(activeToolProvider.notifier).close(),
                icon: const Icon(Icons.close, size: 16, color: BezelColors.textSecondary),
              ),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: ToolPanelBody(tool: tool),
            ),
          ),
        ]),
      ),
    );
  }
}
