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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('MOTION PRESETS', style: AppTypography.panelHeader),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
              itemCount: MotionPresets.allPresets.length,
              itemBuilder: (context, index) {
                final presetData = MotionPresets.allPresets[index];
                final String name = presetData['name'] as String;
                final timeline = presetData['timeline'];
                final bool isSelected = activeTimeline == timeline;
                final icon = _getIconForPreset(name);

                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      final newBlock = SequenceBlock(name: name, timeline: timeline);
                      ref.read(activeSequenceProvider.notifier).state =
                          activeSequence.copyWith(blocks: [newBlock]);
                      ref.read(activeBlockIndexProvider.notifier).state = 0;
                      ref.read(currentPlaybackTimeProvider.notifier).state = Duration.zero;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.control),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, size: 14, color: isSelected ? AppColors.accent : AppColors.secondaryText),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.uiBody.copyWith(
                                color: isSelected ? AppColors.accent : AppColors.primaryText,
                              ),
                            ),
                          ),
                          if (hasSequence)
                            GestureDetector(
                              onTap: () {
                                final newBlock = SequenceBlock(name: name, timeline: timeline);
                                ref.read(activeSequenceProvider.notifier).state =
                                    activeSequence.withAppendedBlock(newBlock);
                              },
                              child: const Icon(Icons.add, size: 14, color: AppColors.secondaryText),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
