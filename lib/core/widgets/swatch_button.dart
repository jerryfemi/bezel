import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import 'pressable.dart';

/// A colour chip with a ring when selected. 44 px hit area.
class SwatchButton extends StatelessWidget {
  const SwatchButton({
    super.key,
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
    this.round = true,
    this.size = 28,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool round;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = round ? size / 2 : 8.0;
    return Tooltip(
      message: label,
      child: Pressable(
        onTap: onTap,
        label: label,
        selected: selected,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: BezelColors.strokeStrong),
                boxShadow: selected
                    ? const [
                        BoxShadow(color: Color(0xFF1E1E23), spreadRadius: 2),
                        BoxShadow(color: BezelColors.textPrimary, spreadRadius: 4),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
