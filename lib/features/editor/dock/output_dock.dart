import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/pressable.dart';
import 'frame_shape_menu.dart';

/// Bottom-left dock: frame shape, motion summary and Export.
/// Motion (phase 5) and Export (phase 6) are shown but not active yet.
class OutputDock extends StatelessWidget {
  const OutputDock({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingSurface(
      padding: const EdgeInsets.all(8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const FrameShapeMenu(),
        _divider(),
        Tooltip(
          message: 'Motion editing is coming next',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No motion yet', style: BezelType.label),
                Text('Still image', style: BezelType.caption),
              ],
            ),
          ),
        ),
        _divider(),
        const SizedBox(width: BezelSpace.s8),
        Tooltip(
          message: 'Export arrives with motion',
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
