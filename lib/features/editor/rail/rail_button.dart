import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../core/widgets/pressable.dart';

/// A rail button: icon over a short name. Selected gets a soft accent tint.
class RailButton extends StatelessWidget {
  const RailButton({
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
    final color = selected ? const Color(0xFFB9CCFF) : BezelColors.textSecondary;
    return Pressable(
      onTap: onTap,
      label: label,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 48,
        height: 50,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0x382F62E0) : null,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color, height: 1),
          ),
        ]),
      ),
    );
  }
}
