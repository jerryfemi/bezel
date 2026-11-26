import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../model/clips.dart';
import '../state/timeline_actions.dart';
import '../state/tracks_provider.dart';
import 'track_style.dart';

/// The fixed column left of the tracks: each track's name, then mute (for
/// tracks with sound), lock, and + to add to it.
class TrackHeaders extends ConsumerWidget {
  const TrackHeaders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = TimelineActions(ref);
    return SizedBox(
      width: TrackStyle.headerWidth,
      child: Column(children: [
        const SizedBox(height: TrackStyle.rulerHeight),
        for (final kind in TrackStyle.order) ...[
          SizedBox(
            height: TrackStyle.of(kind).height,
            child: _Header(
              kind: kind,
              onAdd: switch (kind) {
                TrackKind.caption => actions.addCaption,
                TrackKind.screen => actions.addScreen,
                TrackKind.motion => actions.addKeyframe,
                TrackKind.audio => actions.addAudio,
              },
            ),
          ),
          const SizedBox(height: TrackStyle.gap),
        ],
      ]),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.kind, required this.onAdd});

  final TrackKind kind;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = TrackStyle.of(kind);
    final tracks = ref.read(tracksProvider.notifier);
    final muted = ref.watch(tracksProvider.select((t) => t.mutedTracks.contains(kind)));
    final locked = ref.watch(tracksProvider.select((t) => t.lockedTracks.contains(kind)));
    final hasSound = kind == TrackKind.screen || kind == TrackKind.audio;
    final addLabel = switch (kind) {
      TrackKind.caption => 'Add caption at the playhead',
      TrackKind.screen => 'Add a screenshot or recording',
      TrackKind.motion => 'Add a keyframe at the playhead',
      TrackKind.audio => 'Add music or sound',
    };
    return Row(children: [
      Container(
        width: 3,
        height: style.height - 12,
        decoration: BoxDecoration(color: style.edge, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(style.label,
            style: BezelType.caption.copyWith(
                color: locked ? BezelColors.textTertiary : BezelColors.textSecondary,
                fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis),
      ),
      if (hasSound)
        IconToolButton(
          icon: muted ? BezelIcons.muted : BezelIcons.volume,
          tooltip: muted ? 'Unmute ${style.label.toLowerCase()}' : 'Mute ${style.label.toLowerCase()}',
          selected: muted,
          onTap: () => tracks.toggleTrackMute(kind),
          size: 24,
        ),
      IconToolButton(
        icon: BezelIcons.lock,
        tooltip: locked ? 'Unlock track' : 'Lock track',
        selected: locked,
        onTap: () => tracks.toggleTrackLock(kind),
        size: 24,
      ),
      IconToolButton(icon: BezelIcons.add, tooltip: addLabel, onTap: locked ? null : onAdd, size: 24),
      const SizedBox(width: 4),
    ]);
  }
}
