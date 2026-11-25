import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/pressable.dart';
import '../../export/state/export_provider.dart';
import '../state/active_tool_provider.dart';
import 'zoom_menu.dart';

/// Top-right: zoom and Export. Play lives in the timeline toolbar.
class CornerBar extends ConsumerWidget {
  const CornerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportOpen = ref.watch(exportSheetOpenProvider);
    return FloatingSurface(
      radius: 14,
      padding: const EdgeInsets.all(5),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const ZoomMenu(),
        const SizedBox(width: 4),
        Pressable(
          onTap: () {
            ref.read(activeToolProvider.notifier).close();
            ref.read(exportSheetOpenProvider.notifier).state = !exportOpen;
          },
          label: 'Export',
          selected: exportOpen,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: BezelColors.accent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(children: [
              const Icon(BezelIcons.export, size: 15, color: Colors.white),
              const SizedBox(width: 7),
              Text('Export',
                  style: BezelType.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}
