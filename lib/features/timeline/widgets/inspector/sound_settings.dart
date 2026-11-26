import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/bezel_colors.dart';
import '../../../../app/theme/bezel_icons.dart';
import '../../../../app/theme/bezel_type.dart';
import '../../../../core/widgets/icon_tool_button.dart';
import '../../../../core/widgets/slider_row.dart';
import '../../model/clips.dart';
import '../../state/tracks_provider.dart';

/// Volume with a mute button, then the fade-in and fade-out.
class SoundSettings extends ConsumerWidget {
  const SoundSettings({super.key, required this.clip, required this.clipRef});

  final MediaClip clip;
  final ClipRef clipRef;

  static const _maxFade = 5.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.read(tracksProvider.notifier);
    final maxFade = math.min(_maxFade, clip.length);
    String secs(double v) => '${v.toStringAsFixed(1)} s';

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Text('Volume', style: BezelType.label),
        const Spacer(),
        Text(clip.muted ? 'Muted' : '${(clip.volume * 100).round()}%', style: BezelType.mono),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        IconToolButton(
          icon: clip.muted || clip.volume == 0 ? BezelIcons.muted : BezelIcons.volume,
          tooltip: clip.muted ? 'Unmute' : 'Mute',
          selected: clip.muted,
          size: 30,
          onTap: () => tracks.setMuted(clipRef, !clip.muted),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 28,
            child: Opacity(
              opacity: clip.muted ? 0.45 : 1,
              child: Slider(
                value: clip.volume,
                onChanged: (v) => tracks.setVolume(clipRef, v),
              ),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      SliderRow(
        label: 'Fade in',
        value: clip.fadeIn,
        min: 0,
        max: maxFade,
        format: secs,
        onChanged: (v) => tracks.setFades(clipRef, fadeIn: v),
      ),
      const SizedBox(height: 6),
      SliderRow(
        label: 'Fade out',
        value: clip.fadeOut,
        min: 0,
        max: maxFade,
        format: secs,
        onChanged: (v) => tracks.setFades(clipRef, fadeOut: v),
      ),
      const SizedBox(height: 8),
      Text('Fades are heard in the preview and in the exported video.',
          style: BezelType.caption.copyWith(color: BezelColors.textTertiary, height: 1.4)),
    ]);
  }
}
