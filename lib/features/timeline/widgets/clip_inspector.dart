import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/slider_row.dart';
import '../../motion/widgets/format_time.dart';
import '../../motion/widgets/keyframe_inspector.dart';
import '../../tools/media/screen_media_provider.dart';
import '../../tools/text/text_panel.dart';
import '../model/clips.dart';
import '../state/assets_provider.dart';
import '../state/playhead_provider.dart';
import '../state/timeline_actions.dart';
import '../state/tracks_provider.dart';

/// Right panel in Timeline mode: settings for the selected clip, or the
/// selected keyframe when no clip is selected.
class ClipInspector extends ConsumerWidget {
  const ClipInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ref0 = ref.watch(selectedClipProvider);
    final clip = ref.watch(tracksProvider).find(ref0);
    if (ref0 == null || clip == null) return const KeyframeInspector();

    final title = switch (ref0.track) {
      TrackKind.caption => 'Caption',
      TrackKind.screen => 'Screen',
      TrackKind.audio => 'Audio',
      TrackKind.motion => 'Motion',
    };
    return FloatingSurface(
      radius: BezelRadius.panel,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('$title · ${formatClipTime(clip.start)} – ${formatClipTime(clip.end)}',
              style: BezelType.title),
          const SizedBox(height: 14),
          if (clip is CaptionClip) const TextPanel() else _MediaSettings(clip: clip as MediaClip, track: ref0.track),
          if (clip is! CaptionClip) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => TimelineActions(ref).delete(),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete clip'),
                style: TextButton.styleFrom(foregroundColor: BezelColors.danger),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _MediaSettings extends ConsumerWidget {
  const _MediaSettings({required this.clip, required this.track});

  final MediaClip clip;
  final TrackKind track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(assetsProvider)[clip.assetId];
    final clipRef = ClipRef(track, clip.id);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(asset?.name ?? 'Missing file',
          style: BezelType.label.copyWith(fontWeight: FontWeight.w600),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 4),
      Text(
        asset?.duration == null
            ? 'Image · drag its edges on the timeline to set how long it shows'
            : 'Plays ${formatClipTime(clip.inPoint)} – ${formatClipTime(clip.inPoint + clip.length)} '
                'of ${formatClipTime(asset!.duration!)}',
        style: BezelType.caption.copyWith(height: 1.4),
      ),
      if (asset?.hasSound ?? false) ...[
        const SizedBox(height: 14),
        SliderRow(
          label: 'Volume',
          value: clip.volume,
          min: 0,
          max: 1,
          format: (v) => v == 0 ? 'Muted' : '${(v * 100).round()}%',
          onChanged: (v) => ref.read(tracksProvider.notifier).setVolume(clipRef, v),
        ),
      ],
      if (track == TrackKind.screen) ...[
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ChipButton(
            icon: Icons.swap_horiz,
            label: 'Replace file',
            onTap: () => ref.read(screenMediaProvider.notifier).pick(),
          ),
        ),
      ],
    ]);
  }
}
