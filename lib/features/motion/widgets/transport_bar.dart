import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/pressable.dart';
import '../../editor/state/scene_provider.dart';
import '../state/segment_loop_provider.dart';
import '../state/timeline_provider.dart';
import 'format_time.dart';
import 'loop_chip.dart';
import 'timeline_zoom_controls.dart';

/// Play / pause, the clock, Add keyframe and Loop.
class TransportBar extends ConsumerWidget {
  const TransportBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(sceneControllerProvider);
    final timeline = ref.watch(timelineProvider);
    final notifier = ref.read(timelineProvider.notifier);
    if (scene == null) return const SizedBox(height: 44);

    return SizedBox(
      height: 44,
      child: Row(children: [
        ValueListenableBuilder<bool>(
          valueListenable: scene.playing,
          builder: (_, playing, __) => Pressable(
            onTap: timeline.isEmpty
                ? null
                : () {
                    if (playing) return scene.pause();
                    ref.read(segmentLoopProvider.notifier).stop(); // play the whole clip
                    scene.play();
                  },
            label: playing ? 'Pause' : 'Play',
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(color: BezelColors.textPrimary, shape: BoxShape.circle),
              child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20, color: BezelColors.canvas),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ValueListenableBuilder<double>(
          valueListenable: scene.time,
          builder: (_, t, __) => Text.rich(TextSpan(children: [
            TextSpan(text: formatClipTime(t), style: BezelType.mono),
            TextSpan(
              text: '  /  ${formatClipTime(timeline.duration)}',
              style: BezelType.mono.copyWith(color: BezelColors.textTertiary),
            ),
          ])),
        ),
        const SizedBox(width: 16),
        ChipButton(
          icon: Icons.add,
          label: 'Add keyframe',
          onTap: () => notifier.addKeyframeAt(scene.time.value),
        ),
        const SizedBox(width: 12),
        const LoopChip(),
        const Spacer(),
        const TimelineZoomControls(),
        const SizedBox(width: 12),
        Text('Loop', style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
        const SizedBox(width: 6),
        Switch(
          value: timeline.loop,
          onChanged: notifier.setLoop,
          activeTrackColor: BezelColors.accent,
          activeThumbColor: Colors.white,
        ),
      ]),
    );
  }
}
