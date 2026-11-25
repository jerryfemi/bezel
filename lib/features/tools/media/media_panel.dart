import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
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
        child: MediaPreviewRow(
          media: media,
          onVideo: () => notifier.pick(video: true),
          onImage: () => notifier.pick(video: false),
        ),
      ),
      if (!media.isEmpty) ...[
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: ChipButton(
            icon: Icons.add,
            label: 'Add another after the playhead',
            onTap: notifier.addAnother,
          ),
        ),
      ],
      if (media.error != null) ...[
        const SizedBox(height: 8),
        Text(media.error!, style: BezelType.label.copyWith(color: BezelColors.danger)),
      ],
      const SizedBox(height: 18),
      PanelSection(title: 'Back screen', child: _BackScreenNote()),
    ]);
  }
}

class _BackScreenNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(BezelRadius.control + 2),
        border: Border.all(color: BezelColors.stroke),
      ),
      child: Row(children: [
        const Icon(Icons.flip_to_back, size: 18, color: BezelColors.textTertiary),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Available on two-screen devices.',
              style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
        ),
      ]),
    );
  }
}
