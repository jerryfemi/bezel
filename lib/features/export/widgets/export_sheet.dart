import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../state/export_provider.dart';
import 'export_options.dart';
import 'export_progress.dart';

/// Opens above the Export button. Settings first, then progress and result.
class ExportSheet extends ConsumerWidget {
  const ExportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(exportProvider);
    final idle = s.status == ExportStatus.idle;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380, maxHeight: 560),
      child: FloatingSurface(
        elevated: true,
        radius: BezelRadius.panel,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 6, 2),
            child: Row(children: [
              Text('Export', style: BezelType.title),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                onPressed: s.status == ExportStatus.rendering
                    ? null
                    : () => ref.read(exportSheetOpenProvider.notifier).state = false,
                icon: const Icon(Icons.close, size: 16, color: BezelColors.textSecondary),
              ),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: idle
                  ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const ExportOptions(),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: ref.read(exportProvider.notifier).start,
                        style: FilledButton.styleFrom(
                          backgroundColor: BezelColors.accent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(42),
                        ),
                        child: Text('Export ${s.settings.format.label}'),
                      ),
                    ])
                  : const ExportProgress(),
            ),
          ),
        ]),
      ),
    );
  }
}
