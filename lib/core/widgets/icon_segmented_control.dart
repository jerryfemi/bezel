import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_metrics.dart';
import 'pressable.dart';

/// A row of mutually exclusive icon buttons, each with a tooltip.
class IconSegmentedControl<T> extends StatelessWidget {
  const IconSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  /// Option → (icon, tooltip), in display order.
  final Map<T, (IconData, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x59000000),
        borderRadius: BorderRadius.circular(BezelRadius.control - 1),
      ),
      child: Row(children: [
        for (final MapEntry(key: option, value: (icon, tip)) in options.entries)
          Expanded(
            child: Tooltip(
              message: tip,
              waitDuration: const Duration(milliseconds: 500),
              child: Pressable(
                onTap: () => onChanged(option),
                label: tip,
                selected: option == selected,
                pressedScale: 0.95,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 30,
                  decoration: BoxDecoration(
                    color: option == selected ? BezelColors.selected : null,
                    borderRadius: BorderRadius.circular(BezelRadius.control - 3),
                  ),
                  child: Icon(icon,
                      size: 17,
                      color: option == selected
                          ? BezelColors.textPrimary
                          : BezelColors.textSecondary),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
