import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/pressable.dart';
import 'frame_shape_menu.dart';
import 'motion_summary.dart';

/// Bottom-left dock: frame shape, motion summary and Export.
/// Export becomes active in phase 6.
class OutputDock extends StatelessWidget {
  const OutputDock({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingSurface(
      padding: const EdgeInsets.all(8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const FrameShapeMenu(),
        _divider(),
        const MotionSummary(),
        _divider(),
        const SizedBox(width: BezelSpace.s8),
        Tooltip(
          message: 'Export arrives in the next phase',
          child: Pressable(
            onTap: null,
            label: 'Export',
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: BezelColors.accent,
                borderRadius: BorderRadius.circular(BezelRadius.control + 1),
              ),
              child: Row(children: [
                const Icon(Icons.file_download_outlined, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text('Export', style: BezelType.body.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 24, color: BezelColors.stroke,
      margin: const EdgeInsets.symmetric(horizontal: 4));
}
