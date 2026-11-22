import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';
import '../../motion/state/timeline_provider.dart';
import '../../motion/widgets/format_time.dart';
import '../state/editor_mode_provider.dart';
import '../state/scene_provider.dart';

/// In the Design dock: play the clip, and a summary that opens Motion mode.
class MotionSummary extends ConsumerWidget {
  const MotionSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    final scene = ref.watch(sceneControllerProvider);
    final hasMotion = !timeline.isEmpty;

    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (scene != null)
        ValueListenableBuilder<bool>(
          valueListenable: scene.playing,
          builder: (_, playing, __) => Pressable(
            onTap: hasMotion ? (playing ? scene.pause : scene.play) : null,
            label: playing ? 'Pause' : 'Play',
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(color: BezelColors.textPrimary, shape: BoxShape.circle),
                  child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 18, color: BezelColors.canvas),
                ),
              ),
            ),
          ),
        ),
      Pressable(
        onTap: () => ref.read(editorModeProvider.notifier).state = EditorMode.motion,
        label: 'Edit motion',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(hasMotion ? '${timeline.keyframes.length} keyframes' : 'No motion yet',
                style: BezelType.label),
            Text(hasMotion ? '${formatClipTime(timeline.duration)} · Edit motion' : 'Add motion',
                style: BezelType.caption.copyWith(color: BezelColors.accentLine)),
          ]),
        ),
      ),
    ]);
  }
}
