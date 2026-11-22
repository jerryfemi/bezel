import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/panel_section.dart';
import 'media_preview_row.dart';
import 'screen_media_provider.dart';

class MediaPanel extends ConsumerWidget {
  const MediaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = ref.watch(screenMediaProvider);
    final notifier = ref.read(screenMediaProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PanelSection(
        title: 'Front screen',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          MediaPreviewRow(media: media),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => notifier.pick(video: true),
              child: const Text('Screen recording'),
            )),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(
              onPressed: () => notifier.pick(video: false),
              child: const Text('Screenshot'),
            )),
          ]),
          if (media.error != null) ...[
            const SizedBox(height: 8),
            Text(media.error!, style: BezelType.label.copyWith(color: BezelColors.danger)),
          ],
        ]),
      ),
      const SizedBox(height: 18),
      PanelSection(
        title: 'Back screen',
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(BezelRadius.control + 2),
          ),
          child: Text(
            'This device has one screen. A two-screen device is on the way.',
            style: BezelType.label.copyWith(color: BezelColors.textSecondary, height: 1.45),
          ),
        ),
      ),
    ]);
  }
}
