import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_type.dart';
import 'pressable.dart';

/// A compact icon + label button for secondary actions inside panels.
class ChipButton extends StatelessWidget {
  const ChipButton({super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      label: label,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: BezelColors.stroke),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: BezelColors.textPrimary),
          const SizedBox(width: 6),
          Text(label, style: BezelType.label),
        ]),
      ),
    );
  }
}
