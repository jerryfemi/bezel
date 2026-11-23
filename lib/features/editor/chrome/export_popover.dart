import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_motion.dart';
import '../../export/state/export_provider.dart';
import '../../export/widgets/export_sheet.dart';

/// The export sheet, dropping down from the Export button.
class ExportPopover extends ConsumerWidget {
  const ExportPopover({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(exportSheetOpenProvider);
    return AnimatedSwitcher(
      duration: BezelMotion.of(context, BezelMotion.panel),
      switchInCurve: BezelMotion.settle,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(animation),
          alignment: Alignment.topRight,
          child: child,
        ),
      ),
      child: open ? const ExportSheet() : const SizedBox.shrink(),
    );
  }
}
