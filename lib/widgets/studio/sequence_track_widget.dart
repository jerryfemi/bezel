import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/motion_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

class SequenceTrackWidget extends ConsumerWidget {
  const SequenceTrackWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sequence = ref.watch(activeSequenceProvider);
    final activeIndex = ref.watch(activeBlockIndexProvider);

    if (sequence.blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        itemCount: sequence.blocks.length,
        separatorBuilder: (ctx, i) => const Icon(
          Icons.arrow_right_alt,
          color: AppColors.border,
          size: 16,
        ),
        itemBuilder: (ctx, i) {
          final block = sequence.blocks[i];
          final isSelected = i == activeIndex;

          return GestureDetector(
            onTap: () {
              ref.read(activeBlockIndexProvider.notifier).state = i;
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withValues(alpha: 0.15)
                    : AppColors.raisedSurface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    block.name,
                    style: AppTypography.uiLabel.copyWith(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  GestureDetector(
                    onTap: () {
                      final newSequence = sequence.withRemovedBlock(i);
                      ref.read(activeSequenceProvider.notifier).state =
                          newSequence;
                      // Update active index if it was pointing out of bounds
                      if (activeIndex >= newSequence.blocks.length) {
                        ref.read(activeBlockIndexProvider.notifier).state =
                            (newSequence.blocks.length - 1).clamp(0, 999);
                      }
                    },
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
