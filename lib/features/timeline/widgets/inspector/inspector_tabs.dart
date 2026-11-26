import 'package:flutter/material.dart';

import '../../../../app/theme/bezel_colors.dart';
import '../../../../app/theme/bezel_type.dart';
import '../../../../core/widgets/pressable.dart';

/// Text tabs with an accent underline under the open one.
class InspectorTabs<T> extends StatelessWidget {
  const InspectorTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> tabs;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        for (final tab in tabs)
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Pressable(
              onTap: () => onChanged(tab),
              label: labelOf(tab),
              selected: tab == selected,
              pressedScale: 0.98,
              child: Container(
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: tab == selected ? BezelColors.accentLine : Colors.transparent,
                    ),
                  ),
                ),
                child: Text(
                  labelOf(tab),
                  style: BezelType.label.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tab == selected ? BezelColors.textPrimary : BezelColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
