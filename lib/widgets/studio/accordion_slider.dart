import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

class AccordionSlider extends StatefulWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const AccordionSlider({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<AccordionSlider> createState() => _AccordionSliderState();
}

class _AccordionSliderState extends State<AccordionSlider> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
            color: Colors.transparent, // Ensure full row is clickable
            child: Row(
              children: [
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 14,
                  color: AppColors.secondaryText,
                ),
                const SizedBox(width: AppSpacing.s4),
                Text(widget.title, style: AppTypography.uiLabel),
                const Spacer(),
                Text(
                  widget.value.toStringAsFixed(2),
                  style: AppTypography.technical,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: AppSpacing.s4, bottom: AppSpacing.s8),
            child: SliderTheme(
              data: const SliderThemeData(
                trackHeight: 2.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
              ),
              child: Slider(
                value: widget.value.clamp(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                activeColor: AppColors.accent,
                inactiveColor: AppColors.border,
                onChanged: widget.onChanged,
              ),
            ),
          ),
      ],
    );
  }
}
