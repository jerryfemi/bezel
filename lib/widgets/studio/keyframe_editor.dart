import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/motion_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import 'accordion_slider.dart';

class KeyframeEditor extends ConsumerWidget {
  const KeyframeEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSequence = ref.watch(activeSequenceProvider);
    final activeBlockIndex = ref.watch(activeBlockIndexProvider);
    final currentTime = ref.watch(currentPlaybackTimeProvider);
    final sceneState = ref.watch(animatedSceneStateProvider);

    if (activeSequence.blocks.isEmpty || activeBlockIndex >= activeSequence.blocks.length) {
      return const SizedBox.shrink();
    }
    
    final activeBlock = activeSequence.blocks[activeBlockIndex];
    final activeTimeline = activeBlock.timeline;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      color: AppColors.surface,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Keyframe Editor', style: AppTypography.uiBody),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Time: ${currentTime.inMilliseconds / 1000}s',
              style: AppTypography.uiLabel.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            AccordionSlider(
              title: 'Duration (s)',
              value: activeTimeline.duration.inMilliseconds / 1000.0,
              min: 0.1,
              max: 5.0,
              onChanged: (val) {
                final newTimeline = activeTimeline.copyWith(
                  duration: Duration(milliseconds: (val * 1000).round()),
                );
                final newBlock = activeBlock.copyWith(timeline: newTimeline);
                ref.read(activeSequenceProvider.notifier).state = 
                    activeSequence.withUpdatedBlock(activeBlockIndex, newBlock);
              },
            ),
            const SizedBox(height: AppSpacing.s8),
            AccordionSlider(
              title: 'Scale',
              value: sceneState.scale,
              min: 0.1,
              max: 3.0,
              onChanged: (val) {
                final newTimeline = activeTimeline.withUpdatedProperty(
                  scale: val,
                  time: currentTime,
                );
                final newBlock = activeBlock.copyWith(timeline: newTimeline);
                ref.read(activeSequenceProvider.notifier).state = 
                    activeSequence.withUpdatedBlock(activeBlockIndex, newBlock);
              },
            ),
            const SizedBox(height: AppSpacing.s8),
            AccordionSlider(
              title: 'Position Y',
              value: sceneState.positionY,
              min: -500.0,
              max: 500.0,
              onChanged: (val) {
                final newTimeline = activeTimeline.withUpdatedProperty(
                  positionY: val,
                  time: currentTime,
                );
                final newBlock = activeBlock.copyWith(timeline: newTimeline);
                ref.read(activeSequenceProvider.notifier).state = 
                    activeSequence.withUpdatedBlock(activeBlockIndex, newBlock);
              },
            ),
            const SizedBox(height: AppSpacing.s8),
            AccordionSlider(
              title: 'Rotation',
              value: sceneState.rotation,
              min: -3.14,
              max: 3.14,
              onChanged: (val) {
                final newTimeline = activeTimeline.withUpdatedProperty(
                  rotation: val,
                  time: currentTime,
                );
                final newBlock = activeBlock.copyWith(timeline: newTimeline);
                ref.read(activeSequenceProvider.notifier).state = 
                    activeSequence.withUpdatedBlock(activeBlockIndex, newBlock);
              },
            ),
          ],
        ),
      ),
    );
  }
}
