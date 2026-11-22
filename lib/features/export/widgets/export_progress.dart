import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../state/export_provider.dart';

/// While rendering: progress and Cancel. After: done or failed, with next steps.
class ExportProgress extends ConsumerWidget {
  const ExportProgress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(exportProvider);
    final notifier = ref.read(exportProvider.notifier);

    return switch (s.status) {
      ExportStatus.rendering => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Text('Rendering frames', style: BezelType.label.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(s.total == 0 ? 'Preparing…' : '${s.frame} / ${s.total}', style: BezelType.mono),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: s.total == 0 ? null : s.progress, minHeight: 6,
              backgroundColor: BezelColors.strokeStrong, color: BezelColors.accentLine,
            ),
          ),
          const SizedBox(height: 10),
          Text('Keep this tab open. The canvas may look stretched until it finishes.',
              style: BezelType.caption.copyWith(color: BezelColors.textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: notifier.cancel, child: const Text('Cancel export')),
        ]),
      ExportStatus.done => _Result(
          icon: Icons.check_circle_outline, color: BezelColors.accentLine,
          title: 'Downloaded', detail: s.message ?? '', action: 'Export another', onAction: notifier.reset),
      ExportStatus.failed => _Result(
          icon: Icons.error_outline, color: BezelColors.danger,
          title: 'Export failed', detail: s.message ?? '', action: 'Back', onAction: notifier.reset),
      ExportStatus.idle => const SizedBox.shrink(),
    };
  }
}

class _Result extends StatelessWidget {
  const _Result({
    required this.icon, required this.color, required this.title,
    required this.detail, required this.action, required this.onAction,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(title, style: BezelType.label.copyWith(fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      Text(detail, style: BezelType.caption.copyWith(color: BezelColors.textSecondary)),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: onAction, child: Text(action)),
    ]);
  }
}
