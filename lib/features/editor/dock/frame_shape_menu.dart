import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
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
      child: SizedBox(
        height: 44,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(width: 10),
          Text(shape.label, style: BezelType.mono),
          const Icon(Icons.expand_more, size: 16, color: BezelColors.textSecondary),
          const SizedBox(width: 6),
        ]),
      ),
    );
  }
}
