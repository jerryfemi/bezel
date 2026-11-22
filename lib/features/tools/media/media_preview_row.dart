import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import 'screen_media_provider.dart';

/// Thumbnail and name of what is on the screen right now.
class MediaPreviewRow extends StatelessWidget {
  const MediaPreviewRow({super.key, required this.media});

  final ScreenMedia media;

  @override
  Widget build(BuildContext context) {
    final title = media.isEmpty ? 'Default wallpaper' : media.name ?? 'Your media';
    final subtitle = media.loading
        ? 'Loading…'
        : media.isEmpty ? 'Add a screenshot or screen recording' : (media.isVideo ? 'Video' : 'Image');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(BezelRadius.control + 2),
      ),
      child: Row(children: [
        _Thumb(media: media),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: BezelType.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(subtitle, style: BezelType.caption),
        ])),
      ]),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.media});

  final ScreenMedia media;

  @override
  Widget build(BuildContext context) {
    final showImage = !media.isEmpty && !media.isVideo;
    return Container(
      width: 30,
      height: 54,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: BezelColors.strokeStrong),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1B2340), Color(0xFF2A1E4A)],
        ),
      ),
      child: showImage
          ? Image.network(media.url!, fit: BoxFit.cover)
          : media.isVideo
              ? const Icon(Icons.play_arrow_rounded, size: 16, color: BezelColors.textPrimary)
              : null,
    );
  }
}
