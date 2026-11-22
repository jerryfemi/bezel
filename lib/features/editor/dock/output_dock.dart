import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/pressable.dart';
import '../../export/state/export_provider.dart';
import '../state/active_tool_provider.dart';
import 'frame_shape_menu.dart';
import 'motion_summary.dart';

/// Bottom-left dock: frame shape, motion summary and Export.
class OutputDock extends ConsumerWidget {
  const OutputDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(exportSheetOpenProvider);
    return FloatingSurface(
      padding: const EdgeInsets.all(8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const FrameShapeMenu(),
        _divider(),
        const MotionSummary(),
        _divider(),
        const SizedBox(width: BezelSpace.s8),
        Pressable(
          onTap: () {
            ref.read(activeToolProvider.notifier).close();
            ref.read(exportSheetOpenProvider.notifier).state = !open;
          },
          label: 'Export',
          selected: open,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: BezelColors.accent,
              borderRadius: BorderRadius.circular(BezelRadius.control + 1),
              boxShadow: open
                  ? const [BoxShadow(color: Color(0x738FB0FF), spreadRadius: 3)]
                  : null,
            ),
            child: Row(children: [
              const Icon(Icons.file_download_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text('Export', style: BezelType.body.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 24, color: BezelColors.stroke,
      margin: const EdgeInsets.symmetric(horizontal: 4));
}
