import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import 'screen_media_provider.dart';
import 'screen_thumb.dart';

/// What is on the screen, with buttons to put a video or image there.
class MediaPreviewRow extends StatelessWidget {
  const MediaPreviewRow({
    super.key,
    required this.media,
    required this.onVideo,
    required this.onImage,
  });

  final ScreenMedia media;
  final VoidCallback onVideo;
  final VoidCallback onImage;

  @override
  Widget build(BuildContext context) {
    final title = media.isEmpty ? 'Default wallpaper' : media.name ?? 'Your media';
    final subtitle = media.loading
        ? 'Loading…'
        : media.isEmpty
            ? 'Add a screen recording or screenshot'
            : (media.isVideo ? 'Screen recording' : 'Screenshot');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(BezelRadius.control + 4),
      ),
      child: Row(children: [
        ScreenThumb(media: media),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: BezelType.label.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle, style: BezelType.caption.copyWith(color: BezelColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChipButton(icon: Icons.videocam_outlined, label: 'Video', onTap: onVideo),
              ChipButton(icon: Icons.image_outlined, label: 'Image', onTap: onImage),
            ]),
          ]),
        ),
      ]),
    );
  }
}
