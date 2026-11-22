import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import 'mode_switch.dart';
import 'project_title.dart';
import 'zoom_indicator.dart';

/// Brand and project name on the left, mode switch in the centre, device
/// zoom on the right.
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: FloatingSurface(
            radius: BezelRadius.control + 2,
            padding: const EdgeInsets.only(left: 14, right: 4),
            child: SizedBox(
              height: 44,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.smartphone_outlined, size: 18, color: BezelColors.textPrimary),
                const SizedBox(width: 6),
                Text('Bezel', style: BezelType.brand),
                const SizedBox(width: 10),
                Container(width: 1, height: 18, color: BezelColors.strokeStrong),
                const SizedBox(width: 2),
                const ProjectTitle(),
              ]),
            ),
          ),
        ),
        const ModeSwitch(),
        const Align(alignment: Alignment.centerRight, child: ZoomIndicator()),
      ],
    );
  }
}
