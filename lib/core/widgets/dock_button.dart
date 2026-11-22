import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_metrics.dart';
import '../../app/theme/bezel_motion.dart';
import '../../app/theme/bezel_type.dart';
import 'pressable.dart';

/// Icon over a short label, used in the tool dock.
class DockButton extends StatelessWidget {
  const DockButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? BezelColors.textPrimary : BezelColors.textSecondary;
    return Pressable(
      onTap: onTap,
      label: label,
      selected: selected,
      child: AnimatedContainer(
        duration: BezelMotion.of(context, BezelMotion.press),
        width: 76,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? BezelColors.selected : Colors.transparent,
          borderRadius: BorderRadius.circular(BezelRadius.control + 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 3),
            Text(label, style: BezelType.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
