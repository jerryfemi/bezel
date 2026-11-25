import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../state/frame_shape.dart';

/// Picks the clip's shape; the canvas frame follows it.
class FrameShapeMenu extends ConsumerWidget {
  const FrameShapeMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shape = ref.watch(frameShapeProvider);
    return PopupMenuButton<FrameShape>(
      tooltip: 'Frame shape',
      initialValue: shape,
      position: PopupMenuPosition.over,
      offset: const Offset(56, 0),
      onSelected: (s) => ref.read(frameShapeProvider.notifier).state = s,
      itemBuilder: (_) => [
        for (final s in FrameShape.values)
          PopupMenuItem(
            value: s,
            child: Row(children: [
              SizedBox(width: 44, child: Text(s.label, style: BezelType.mono)),
              Text(s.usedFor, style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
            ]),
          ),
      ],
      // Sized for the 60px rail: the ratio over a small chevron.
      child: SizedBox(
        width: 48,
        height: 40,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(shape.label, style: BezelType.label.copyWith(fontWeight: FontWeight.w600)),
          const Icon(BezelIcons.chevronDown, size: 12, color: BezelColors.textSecondary),
        ]),
      ),
    );
  }
}
