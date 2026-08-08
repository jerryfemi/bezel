import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

class StudioSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> segments;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;

  const StudioSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.raisedSurface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: segments.entries.map((entry) {
          final isSelected = entry.key == selectedValue;
          final isFirst = entry.key == segments.keys.first;
          final isLast = entry.key == segments.keys.last;

          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(entry.key),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.border : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(isFirst ? AppRadius.control - 1 : 0),
                    right: Radius.circular(isLast ? AppRadius.control - 1 : 0),
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: AppTypography.uiLabel.copyWith(
                      color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
