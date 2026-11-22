import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';
import 'pose_presets.dart';

/// A preset shown as a small tilted phone. (Rendered thumbnails from the
/// real model can replace the drawn phone later.)
class PoseTile extends StatelessWidget {
  const PoseTile({super.key, required this.preset, required this.selected, required this.onTap});

  final PosePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rad = math.pi / 180;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.004)
      ..rotateY(preset.pose.turn * rad)
      ..rotateX(-preset.pose.tilt * rad);

    return Pressable(
      onTap: onTap,
      label: preset.name,
      selected: selected,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        decoration: BoxDecoration(
          color: selected ? BezelColors.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(BezelRadius.control + 2),
          border: Border.all(color: selected ? BezelColors.accentLine : BezelColors.stroke),
        ),
        child: Column(children: [
          Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              gradient: const RadialGradient(
                center: Alignment(0, -0.4),
                colors: [Color(0xFF2B3447), Color(0xFF161A22)],
              ),
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: transform,
              child: Container(
                width: 22,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF20242E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF9A958D), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(preset.name, style: BezelType.label),
        ]),
      ),
    );
  }
}
