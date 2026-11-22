import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import 'screen_media_provider.dart';

/// A phone-shaped thumbnail of what is on the screen.
class ScreenThumb extends StatelessWidget {
  const ScreenThumb({super.key, required this.media});

  final ScreenMedia media;

  @override
  Widget build(BuildContext context) {
    final showImage = !media.isEmpty && !media.isVideo;
    return Container(
      width: 44,
      height: 92,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C3D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B2340), Color(0xFF2A1E4A)],
          ),
        ),
        child: showImage
            ? Image.network(media.url!, fit: BoxFit.cover)
            : media.isVideo
                ? const Icon(Icons.play_arrow_rounded, size: 20, color: BezelColors.textPrimary)
                : null,
      ),
    );
  }
}
