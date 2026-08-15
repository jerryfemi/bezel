import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/motion_provider.dart';
import '../../models/motion/presets.dart';
import '../../models/motion/sequence_block.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

class PresetSelector extends ConsumerWidget {
  const PresetSelector({super.key});

  IconData _getIconForPreset(String name) {
    switch (name) {
      case 'Push In':
        return Icons.zoom_in;
      case 'Pull Out':
        return Icons.zoom_out;
      case 'Pan Up':
        return Icons.keyboard_arrow_up;
      case 'Pan Down':
        return Icons.keyboard_arrow_down;
      case 'Twist':
        return Icons.rotate_right;
      case 'Reveal':
        return Icons.auto_awesome;
      case 'Hero':
        return Icons.stars;
      case 'Slam':
        return Icons.bolt;
      case 'Float':
        return Icons.waves;
      case 'Iso Slide':
        return Icons.transform;
      case 'Whip Pan':
        return Icons.speed;
      default:
        return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSequence = ref.watch(activeSequenceProvider);
    final activeBlockIndex = ref.watch(activeBlockIndexProvider);
    final hasSequence = activeSequence.blocks.isNotEmpty;

    // Determine the timeline of the currently selected block, if any
    final activeTimeline =
        hasSequence && activeBlockIndex < activeSequence.blocks.length
        ? activeSequence.blocks[activeBlockIndex].timeline
        : null;

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Text('Motion Presets', style: AppTypography.uiBody),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: AppSpacing.s8,
                mainAxisSpacing: AppSpacing.s8,
              ),
              itemCount: MotionPresets.allPresets.length,
              itemBuilder: (context, index) {
                final presetData = MotionPresets.allPresets[index];
                final String name = presetData['name'] as String;
                // timeline is a method returning Timeline or a Timeline object depending on how it's defined
                final timeline = presetData['timeline'];
                final bool isSelected = activeTimeline == timeline;
                final icon = _getIconForPreset(name);

                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Replace the entire sequence with just this block
                        final newBlock = SequenceBlock(
                          name: name,
                          timeline: timeline,
                        );
                        ref.read(activeSequenceProvider.notifier).state =
                            activeSequence.copyWith(blocks: [newBlock]);
                        ref.read(activeBlockIndexProvider.notifier).state = 0;
                        ref.read(currentPlaybackTimeProvider.notifier).state =
                            Duration.zero;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : AppColors.raisedSurface,
                          borderRadius: BorderRadius.circular(
                            AppRadius.control,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.smartphone,
                                    size: 56,
                                    color: isSelected
                                        ? AppColors.primaryText
                                        : AppColors.secondaryText,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.border,
                                        ),
                                      ),
                                      child: Icon(
                                        icon,
                                        size: 16,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.s8),
                              child: Text(
                                name,
                                style: AppTypography.uiLabel.copyWith(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.primaryText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // The "Add to Sequence" button, visible if a sequence exists and this isn't the active one
                    if (hasSequence)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            // Append to sequence
                            final newBlock = SequenceBlock(
                              name: name,
                              timeline: timeline,
                            );
                            ref.read(activeSequenceProvider.notifier).state =
                                activeSequence.withAppendedBlock(newBlock);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
