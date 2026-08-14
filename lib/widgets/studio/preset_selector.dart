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
      default:
        return Icons.play_arrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimeline = ref.watch(activeTimelineProvider);

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
                final Timeline timeline = presetData['timeline'] as Timeline;
                final bool isSelected = activeTimeline == timeline;
                final icon = _getIconForPreset(name);

                return GestureDetector(
                  onTap: () {
                    ref.read(activeTimelineProvider.notifier).state = timeline;
                    ref.read(currentPlaybackTimeProvider.notifier).state =
                        Duration.zero;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withOpacity(0.15)
                          : AppColors.raisedSurface,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(
                        color: isSelected ? AppColors.accent : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // The "Device"
                              Icon(
                                Icons.smartphone,
                                size: 56,
                                color: isSelected
                                    ? AppColors.primaryText
                                    : AppColors.secondaryText,
                              ),
                              // The Motion Overlay
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
