import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_motion.dart';
import '../timeline/widgets/clip_inspector.dart';
import 'state/editor_layout.dart';

/// The right panel: settings for whatever is selected on the timeline.
/// Slides in from the right edge when something is selected, and back out.
class InspectorHost extends ConsumerWidget {
  const InspectorHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(inspectorVisibleProvider);
    return AnimatedSwitcher(
      duration: BezelMotion.of(context, BezelMotion.panel),
      switchInCurve: BezelMotion.settle,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, ?current]),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0.06, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: visible ? const ClipInspector() : const SizedBox.shrink(),
    );
  }
}
