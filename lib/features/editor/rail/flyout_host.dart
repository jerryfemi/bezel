import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_motion.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../tools/tool_panel_body.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';

/// The open tool's panel, beside the rail. It slides out of the rail and
/// back into it, so it always comes and goes the same way.
class FlyoutHost extends ConsumerWidget {
  const FlyoutHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(activeToolProvider);
    return AnimatedSwitcher(
      duration: BezelMotion.of(context, BezelMotion.panel),
      switchInCurve: BezelMotion.settle,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, if (current != null) current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(-0.06, 0), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: tool == null ? const SizedBox.shrink() : _Flyout(key: ValueKey(tool), tool: tool),
    );
  }
}

class _Flyout extends ConsumerWidget {
  const _Flyout({super.key, required this.tool});

  final EditorTool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingSurface(
      radius: BezelRadius.panel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 6, 2),
          child: Row(children: [
            Text(tool.label, style: BezelType.title),
            const Spacer(),
            IconToolButton(
              icon: BezelIcons.close,
              tooltip: 'Close',
              shortcut: 'Esc',
              size: 30,
              onTap: () => ref.read(activeToolProvider.notifier).close(),
            ),
          ]),
        ),
        Container(height: 1, color: BezelColors.stroke, margin: const EdgeInsets.only(top: 4)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: ToolPanelBody(tool: tool),
          ),
        ),
      ]),
    );
  }
}
