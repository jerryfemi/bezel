import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import 'pressable.dart';

/// A square icon button with a tooltip (and optional shortcut hint), as used
/// in the dock and the corner bars.
class IconToolButton extends StatelessWidget {
  const IconToolButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.shortcut,
    this.selected = false,
    this.size = 36,
  });

  final IconData icon;
  final String tooltip;
  final String? shortcut;
  final VoidCallback? onTap;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: shortcut == null ? tooltip : '$tooltip   $shortcut',
      waitDuration: const Duration(milliseconds: 400),
      child: Pressable(
        onTap: onTap,
        label: tooltip,
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected ? BezelColors.accent : null,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 18,
            color: selected
                ? Colors.white
                : enabled ? BezelColors.textPrimary : BezelColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
