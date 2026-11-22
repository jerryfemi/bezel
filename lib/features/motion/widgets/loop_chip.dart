import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';
import '../state/segment_loop_provider.dart';

/// Shown while one move loops on its own; × goes back to the whole clip.
class LoopChip extends ConsumerWidget {
  const LoopChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(segmentLoopProvider) == null) return const SizedBox.shrink();
    return Container(
      height: 30,
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: BezelColors.accentSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BezelColors.accentLine),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.repeat_rounded, size: 14, color: BezelColors.accentLine),
        const SizedBox(width: 6),
        Text('Looping selected move', style: BezelType.caption.copyWith(color: BezelColors.textPrimary)),
        Pressable(
          onTap: ref.read(segmentLoopProvider.notifier).stop,
          label: 'Play the whole clip',
          child: const SizedBox.square(
            dimension: 26,
            child: Icon(Icons.close, size: 14, color: BezelColors.textSecondary),
          ),
        ),
      ]),
    );
  }
}
