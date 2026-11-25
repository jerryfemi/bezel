import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../model/clips.dart';
import '../state/timeline_actions.dart';
import 'track_style.dart';

/// The fixed column left of the tracks: each track's name, with + to add to it.
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

class _Header extends StatelessWidget {
  const _Header({required this.kind, required this.onAdd});

  final TrackKind kind;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final style = TrackStyle.of(kind);
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
      Icon(style.icon, size: 14, color: BezelColors.textSecondary),
      const SizedBox(width: 6),
      Expanded(
        child: Text(style.label,
            style: BezelType.caption.copyWith(color: BezelColors.textSecondary),
            overflow: TextOverflow.ellipsis),
      ),
      IconToolButton(icon: BezelIcons.add, tooltip: addLabel, onTap: onAdd, size: 26),
      const SizedBox(width: 6),
    ]);
  }
}
