import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_motion.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/pressable.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_mode_provider.dart';

/// Design / Motion switch in the top bar.
class ModeSwitch extends ConsumerWidget {
  const ModeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(editorModeProvider);
    void select(EditorMode m) {
      ref.read(activeToolProvider.notifier).close();
      ref.read(editorModeProvider.notifier).state = m;
    }

    return FloatingSurface(
      radius: BezelRadius.control + 2,
      padding: const EdgeInsets.all(3),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _Mode('Design', selected: mode == EditorMode.design, onTap: () => select(EditorMode.design)),
        _Mode('Motion', selected: mode == EditorMode.motion, onTap: () => select(EditorMode.motion)),
      ]),
    );
  }
}

class _Mode extends StatelessWidget {
  const _Mode(this.label, {required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      label: label,
      selected: selected,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: BezelMotion.of(context, BezelMotion.press),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? BezelColors.selected : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label, style: BezelType.body.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? BezelColors.textPrimary : BezelColors.textSecondary,
        )),
      ),
    );
  }
}
