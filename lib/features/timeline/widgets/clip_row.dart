import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/state/timeline_provider.dart';
import '../model/clip_ops.dart' as ops;
import '../model/clips.dart';
import '../state/edit_history.dart';
import '../state/playhead_provider.dart';
import '../state/timeline_actions.dart';
import '../state/tracks_provider.dart';
import 'clip_block.dart';
import 'track_style.dart';

/// The clips of one track, placed along time. Moving or trimming snaps to the
/// playhead, to the start, to keyframes, and to the edges of other clips.
class ClipRow extends ConsumerStatefulWidget {
  const ClipRow({
    super.key,
    required this.kind,
    required this.pixelsPerSecond,
    required this.faceFor,
    this.onDoubleTap,
  });

  final TrackKind kind;
  final double pixelsPerSecond;
  final Widget Function(TimedClip clip) faceFor;
  final void Function(TimedClip clip)? onDoubleTap;

  @override
  ConsumerState<ClipRow> createState() => _ClipRowState();
}

class _ClipRowState extends ConsumerState<ClipRow> {
  static const _snapPixels = 8.0;

  TimedClip? _origin; // the clip as it was when the drag began

  double get _pps => widget.pixelsPerSecond;

  List<double> _snapPoints(String exclude) {
    final tracks = ref.read(tracksProvider);
    return [
      0,
      ref.read(playheadProvider),
      for (final kind in [TrackKind.caption, TrackKind.screen, TrackKind.audio])
        for (final c in tracks.on(kind))
          if (c.id != exclude) ...[c.start, c.end],
      for (final k in ref.read(timelineProvider).keyframes) k.time,
    ];
  }

  void _start(TimedClip clip, ClipEdge edge) {
    _origin = clip;
    ref.read(editHistoryProvider.notifier).breakStep();
    TimelineActions(ref).select(ClipRef(widget.kind, clip.id));
  }

  void _drag(ClipEdge edge, double dx) {
    final origin = _origin;
    if (origin == null) return;
    final tracks = ref.read(tracksProvider.notifier);
    final clip = ClipRef(widget.kind, origin.id);
    final points = _snapPoints(origin.id);
    final tolerance = _snapPixels / _pps;
    final dt = dx / _pps;
    switch (edge) {
      case ClipEdge.body:
        final start = origin.start + dt;
        final byStart = ops.snapTo(start, points, tolerance);
        final byEnd = ops.snapTo(start + origin.length, points, tolerance) - origin.length;
        // Use whichever edge found something to snap to (the start wins a tie).
        tracks.move(clip, byStart != start ? byStart : byEnd);
      case ClipEdge.left:
        tracks.trimStart(clip, ops.snapTo(origin.start + dt, points, tolerance));
      case ClipEdge.right:
        tracks.trimEnd(clip, ops.snapTo(origin.end + dt, points, tolerance));
    }
  }

  @override
  Widget build(BuildContext context) {
    final clips = ref.watch(tracksProvider.select((t) => t.on(widget.kind)));
    final selected = ref.watch(selectedClipProvider);
    final style = TrackStyle.of(widget.kind);
    return Stack(clipBehavior: Clip.none, children: [
      for (final clip in clips)
        Positioned(
          left: clip.start * _pps,
          width: (clip.length * _pps).clamp(4.0, double.infinity),
          top: 0,
          bottom: 0,
          child: ClipBlock(
            key: ValueKey(clip.id),
            style: style,
            selected: selected == ClipRef(widget.kind, clip.id),
            onSelect: () => TimelineActions(ref).select(ClipRef(widget.kind, clip.id)),
            onDragStart: (edge) => _start(clip, edge),
            onDrag: _drag,
            onDragEnd: () => _origin = null,
            onDoubleTap: widget.onDoubleTap == null ? null : () => widget.onDoubleTap!(clip),
            child: widget.faceFor(clip),
          ),
        ),
    ]);
  }
}
