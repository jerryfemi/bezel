import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_metrics.dart';
import '../../app/theme/bezel_type.dart';
import 'pressable.dart';

/// A row of mutually exclusive options.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(BezelRadius.control - 1),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(child: _Segment(
              label: labelOf(option),
              selected: option == selected,
              onTap: () => onChanged(option),
            )),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      label: label,
      selected: selected,
      pressedScale: 0.98,
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? BezelColors.selected : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: BezelType.label.copyWith(
            color: selected ? BezelColors.textPrimary : BezelColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
