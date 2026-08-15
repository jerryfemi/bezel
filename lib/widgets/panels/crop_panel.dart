import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import '../studio/studio_slider.dart';
import '../studio/studio_button.dart';
import '../studio/inspector_section.dart';

class CropPanel extends ConsumerWidget {
  final bool isEmbedded;
  const CropPanel({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(mockupProjectProvider);
    final currentScale = project.mediaTransform?.getMaxScaleOnAxis() ?? 1.0;

    return Container(
      width: isEmbedded ? null : 280,
      color: isEmbedded ? Colors.transparent : AppColors.surface,
      padding: isEmbedded ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isEmbedded)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s24),
              child: Text('Crop Media', style: AppTypography.headingMedium),
            ),

          InspectorSection(
            title: 'Media Zoom',
            showDivider: false,
            child: Column(
              children: [
                StudioSlider(
                  label: 'Scale',
                  valueDisplay: '${(currentScale * 100).toInt()}%',
                  value: currentScale.clamp(0.1, 10.0),
                  min: 0.1,
                  max: 10.0,
                  onChanged: (newScale) {
                    // Fix for jitter: read the freshest transform state directly
                    // from the provider inside the callback, not from the stale
                    // build-time variable.
                    final freshProject = ref.read(mockupProjectProvider);
                    final freshTransform = freshProject.mediaTransform?.clone() ?? Matrix4.identity();
                    final freshScale = freshTransform.getMaxScaleOnAxis();
                    final scaleRatio = newScale / freshScale;
                    freshTransform.scale(scaleRatio, scaleRatio, 1.0);
                    ref.read(mockupProjectProvider.notifier).setMediaTransform(freshTransform);
                  },
                ),
                const SizedBox(height: AppSpacing.s16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StudioButton(
                    label: 'Reset Crop',
                    onPressed: () {
                      ref.read(mockupProjectProvider.notifier).setMediaTransform(Matrix4.identity());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
