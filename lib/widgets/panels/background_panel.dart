import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import '../studio/accordion_slider.dart';
import '../studio/studio_button.dart';
import '../studio/inspector_section.dart';

class BackgroundPanel extends ConsumerWidget {
  final bool isEmbedded;
  const BackgroundPanel({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(mockupProjectProvider);

    return Container(
      width: isEmbedded ? null : 280,
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Panel title
          if (!isEmbedded)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s24),
              child: Text('Background', style: AppTypography.headingMedium),
            ),

          // ─── ROTATION ──────────────────────────────────
          InspectorSection(
            title: 'Rotation',
            child: Column(
              children: [
                AccordionSlider(
                  title: 'X Axis',
                  value: project.rotationX,
                  min: -3.14,
                  max: 3.14,
                  onChanged: (val) {
                    ref.read(mockupProjectProvider.notifier).setRotation(val, project.rotationY, project.rotationZ);
                  },
                ),
                AccordionSlider(
                  title: 'Y Axis',
                  value: project.rotationY,
                  min: -3.14,
                  max: 3.14,
                  onChanged: (val) {
                    ref.read(mockupProjectProvider.notifier).setRotation(project.rotationX, val, project.rotationZ);
                  },
                ),
                AccordionSlider(
                  title: 'Z Axis',
                  value: project.rotationZ,
                  min: -3.14,
                  max: 3.14,
                  onChanged: (val) {
                    ref.read(mockupProjectProvider.notifier).setRotation(project.rotationX, project.rotationY, val);
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StudioButton(
                    label: 'Reset',
                    onPressed: () {
                      ref.read(mockupProjectProvider.notifier).setRotation(0, 0, 0);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── BACKGROUND COLOR ──────────────────────────
          InspectorSection(
            title: 'Color',
            showDivider: false,
            child: Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                _ColorSwatch(color: Colors.transparent, selected: project.backgroundColor, isTransparent: true, ref: ref),
                _ColorSwatch(color: const Color(0xFF1A1A1A), selected: project.backgroundColor, ref: ref),
                _ColorSwatch(color: Colors.white, selected: project.backgroundColor, ref: ref),
                _ColorSwatch(color: Colors.black, selected: project.backgroundColor, ref: ref),
                _ColorSwatch(color: const Color(0xFFE91E63), selected: project.backgroundColor, ref: ref),
                _ColorSwatch(color: const Color(0xFF2196F3), selected: project.backgroundColor, ref: ref),
                _ColorSwatch(color: const Color(0xFF4CAF50), selected: project.backgroundColor, ref: ref),
                _ColorSwatch(color: const Color(0xFFFFC107), selected: project.backgroundColor, ref: ref),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final Color selected;
  final bool isTransparent;
  final WidgetRef ref;

  const _ColorSwatch({
    required this.color,
    required this.selected,
    this.isTransparent = false,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = color == selected;
    return GestureDetector(
      onTap: () {
        ref.read(mockupProjectProvider.notifier).setBackgroundColor(color);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isTransparent ? AppColors.raisedSurface : color,
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isTransparent
            ? Icon(Icons.format_color_reset, size: 16, color: AppColors.secondaryText)
            : null,
      ),
    );
  }
}
