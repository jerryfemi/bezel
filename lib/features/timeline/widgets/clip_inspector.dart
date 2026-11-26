import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_type.dart';
import '../../motion/widgets/format_time.dart';
import '../../motion/widgets/keyframe_inspector.dart';
import '../../tools/text/text_panel.dart';
import '../model/clips.dart';
import '../state/assets_provider.dart';
import '../state/playhead_provider.dart';
import '../state/tracks_provider.dart';
import 'inspector/inspector_panel.dart';
import 'inspector/inspector_tabs.dart';
import 'inspector/screen_settings.dart';
import 'inspector/sound_settings.dart';

enum ScreenTab { screen, sound }

/// Which tab a screen clip opens on; kept as you move between clips.
final screenTabProvider = StateProvider<ScreenTab>((ref) => ScreenTab.screen);

/// The right panel for the selected clip (or keyframe).
class ClipInspector extends ConsumerWidget {
  const ClipInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedClipProvider);
    final clip = ref.watch(tracksProvider).find(selected);
    if (selected == null || clip == null) return const KeyframeInspector();

    final when = '${formatClipTime(clip.start)} – ${formatClipTime(clip.end)}';
    if (clip is CaptionClip) {
      return InspectorPanel(title: 'Caption', subtitle: when, child: const TextPanel());
    }

    final media = clip as MediaClip;
    final asset = ref.watch(assetsProvider)[media.assetId];
    if (selected.track == TrackKind.audio) {
      return InspectorPanel(
        title: 'Audio',
        subtitle: '${asset?.name ?? 'Missing file'} · $when',
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SoundSettings(clip: media, clipRef: selected),
          const SizedBox(height: 18),
          const ClipActions(),
        ]),
      );
    }

    final tab = ref.watch(screenTabProvider);
    final hasSound = asset?.hasSound ?? false;
    return InspectorPanel(
      title: 'Screen',
      subtitle: when,
      tabs: InspectorTabs<ScreenTab>(
        tabs: ScreenTab.values,
        selected: tab,
        labelOf: (t) => t == ScreenTab.screen ? 'Screen' : 'Sound',
        onChanged: (t) => ref.read(screenTabProvider.notifier).state = t,
      ),
      child: switch (tab) {
        ScreenTab.screen => ScreenSettings(clip: media, asset: asset),
        ScreenTab.sound when hasSound => SoundSettings(clip: media, clipRef: selected),
        ScreenTab.sound => Text('This is a still image, so it has no sound.',
            style: BezelType.caption.copyWith(height: 1.45)),
      },
    );
  }
}
