import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../editor/state/editor_layout.dart';
import '../../editor/state/scene_provider.dart';
import '../../motion/state/selected_keyframe_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../motion/state/timeline_zoom_provider.dart';
import '../../motion/widgets/format_time.dart';
import '../../motion/widgets/loop_chip.dart';
import '../model/tracks.dart';
import '../state/edit_history.dart';
import '../state/playhead_provider.dart';
import '../state/timeline_actions.dart';
import '../state/tracks_provider.dart';

/// Above the tracks: undo/redo, split and delete on the left; play and the
/// clock in the middle; zoom on the right.
class TimelineToolbar extends ConsumerWidget {
  const TimelineToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = TimelineActions(ref);
    final history = ref.watch(editHistoryProvider);
    final hasSelection =
        ref.watch(selectedClipProvider) != null || ref.watch(selectedKeyframeProvider) != null;
    final length = clipLength(ref.watch(tracksProvider), ref.watch(timelineProvider).duration);
    final scene = ref.watch(sceneControllerProvider);
    final zoom = ref.watch(timelineZoomProvider);
    final zoomer = ref.read(timelineZoomProvider.notifier);
    final folded = ref.watch(timelineFoldedProvider);

    Widget divider() => Container(
        width: 1, height: 18, color: BezelColors.stroke, margin: const EdgeInsets.symmetric(horizontal: 6));

    return SizedBox(
      height: 40,
      child: Row(children: [
        IconToolButton(icon: BezelIcons.undo, tooltip: 'Undo', shortcut: 'Ctrl+Z',
            onTap: history.canUndo ? actions.undo : null, size: 32),
        IconToolButton(icon: BezelIcons.redo, tooltip: 'Redo', shortcut: 'Ctrl+Shift+Z',
            onTap: history.canRedo ? actions.redo : null, size: 32),
        divider(),
        IconToolButton(icon: BezelIcons.split, tooltip: 'Split at the playhead', shortcut: 'S',
            onTap: length > 0 ? actions.split : null, size: 32),
        IconToolButton(icon: BezelIcons.delete, tooltip: 'Delete', shortcut: 'Del',
            onTap: hasSelection ? actions.delete : null, size: 32),
        const SizedBox(width: 8),
        const LoopChip(),
        const Spacer(),
        if (scene != null)
          ValueListenableBuilder<bool>(
            valueListenable: scene.playing,
            builder: (_, playing, __) => IconToolButton(
              icon: playing ? BezelIcons.pause : BezelIcons.play,
              tooltip: playing ? 'Pause' : 'Play',
              shortcut: 'Space',
              onTap: length > 0 ? actions.playPause : null,
              size: 32,
            ),
          ),
        const SizedBox(width: 8),
        if (scene != null)
          ValueListenableBuilder<double>(
            valueListenable: scene.time,
            builder: (_, t, __) => Text.rich(TextSpan(children: [
              TextSpan(text: formatClipTime(t), style: BezelType.mono),
              TextSpan(
                text: '  /  ${formatClipTime(length)}',
                style: BezelType.mono.copyWith(color: BezelColors.textTertiary),
              ),
            ])),
          ),
        const Spacer(),
        IconToolButton(icon: BezelIcons.zoomOut, tooltip: 'Zoom out',
            onTap: zoom > TimelineZoomNotifier.min ? () => zoomer.scaleBy(1 / 1.5) : null, size: 32),
        SizedBox(
          width: 90,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: BezelColors.textSecondary,
              inactiveTrackColor: BezelColors.strokeStrong,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: zoom,
              min: TimelineZoomNotifier.min,
              max: TimelineZoomNotifier.max,
              onChanged: zoomer.set,
            ),
          ),
        ),
        IconToolButton(icon: BezelIcons.zoomIn, tooltip: 'Zoom in',
            onTap: zoom < TimelineZoomNotifier.max ? () => zoomer.scaleBy(1.5) : null, size: 32),
        IconToolButton(icon: BezelIcons.fit, tooltip: 'Fit the whole video',
            onTap: zoom == TimelineZoomNotifier.min ? null : zoomer.fit, size: 32),
        divider(),
        IconToolButton(
          icon: folded ? BezelIcons.chevronUp : BezelIcons.chevronDown,
          tooltip: folded ? 'Show the timeline' : 'Fold the timeline',
          onTap: () => ref.read(timelineFoldedProvider.notifier).state = !folded,
          size: 32,
        ),
      ]),
    );
  }
}
