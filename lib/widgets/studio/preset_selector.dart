import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/motion_provider.dart';
import '../../models/motion/presets.dart';
import '../../models/motion/timeline.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

class PresetSelector extends ConsumerWidget {
  const PresetSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimeline = ref.watch(activeTimelineProvider);

    return Container(
      width: 280,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Text('Motion Presets', style: AppTypography.uiBody),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              itemCount: MotionPresets.allPresets.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.s12),
              itemBuilder: (context, index) {
                final presetData = MotionPresets.allPresets[index];
                final String name = presetData['name'] as String;
                final Timeline timeline = presetData['timeline'] as Timeline;

                final bool isSelected = activeTimeline == timeline;

                return GestureDetector(
                  onTap: () {
                    ref.read(activeTimelineProvider.notifier).state = timeline;
                    // Reset playback time when switching presets
                    ref.read(currentPlaybackTimeProvider.notifier).state =
                        Duration.zero;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.raisedSurface,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Text(
                      name,
                      style: AppTypography.uiLabel.copyWith(
                        color: isSelected
                            ? Colors.black
                            : AppColors.primaryText,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
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
