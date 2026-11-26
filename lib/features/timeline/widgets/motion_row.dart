import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../motion/model/keyframe.dart';
import '../../motion/state/segment_loop_provider.dart';
import '../../motion/state/selected_keyframe_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../motion/widgets/key_edge.dart';
import '../../motion/widgets/segment_drag.dart';
import '../../motion/widgets/segment_drag_overlay.dart';
import '../../motion/widgets/segment_pill.dart';
import '../state/edit_history.dart';
import '../state/playhead_provider.dart';

/// The motion track: each move is a block between two keyframes. Drag the
/// seam between blocks to retime that keyframe (trimming the moves on either
/// side), click a block to loop it, drag a block to reorder it.
class MotionRow extends ConsumerStatefulWidget {
  const MotionRow({super.key, required this.pixelsPerSecond, required this.height});

  final double pixelsPerSecond;
  final double height;

  @override
  ConsumerState<MotionRow> createState() => _MotionRowState();
}

class _MotionRowState extends ConsumerState<MotionRow> {
  int? _dragging; // segment index being carried
  double _dragX = 0;

  double _x(double t) => t * widget.pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    final keys = ref.watch(timelineProvider).keyframes;
    final selected = ref.watch(selectedKeyframeProvider);
    final looping = ref.watch(segmentLoopProvider);
    final mids = [for (var i = 1; i < keys.length; i++) _x((keys[i - 1].time + keys[i].time) / 2)];
    final drop = _dragging == null ? null : dropIndexFor(_dragX, _dragging!, mids);
    const pillTop = 2.0;
    final pillHeight = widget.height - 4;

    return Stack(clipBehavior: Clip.none, children: [
      for (var i = 1; i < keys.length; i++)
        Positioned(
          left: _x(keys[i - 1].time),
          width: math.max(0, _x(keys[i].time) - _x(keys[i - 1].time)),
          top: pillTop,
          height: pillHeight,
          child: SegmentPill(
            easing: keys[i].easing,
            selected: keys[i].id == selected,
            ghost: _dragging == i,
            onTap: () => _selectSegment(keys[i]),
            onDragStart: (d) => setState(() {
              _dragging = i;
              _dragX = _x(keys[i - 1].time) + d.localPosition.dx;
            }),
            onDragUpdate: (d) => setState(() => _dragX += d.delta.dx),
            onDragEnd: () => _drop(drop),
          ),
        ),
      // A lone keyframe is the starting pose: a short block to click.
      if (keys.length == 1)
        Positioned(
          left: _x(keys.first.time),
          top: pillTop,
          width: 44,
          height: pillHeight,
          child: GestureDetector(
            onTap: () => _selectKey(keys.first),
            child: SegmentPillFace(
                easing: keys.first.easing, selected: keys.first.id == selected, label: 'Start'),
          ),
        ),
      for (final k in keys.skip(1))
        Positioned(
          left: _x(k.time) - KeyEdge.hitWidth / 2,
          top: 0,
          width: KeyEdge.hitWidth,
          height: widget.height,
          child: KeyEdge(
            selected: k.id == selected && looping != k.id,
            onTap: () => _selectKey(k),
            onDrag: (dx) => _retime(k.id, dx / widget.pixelsPerSecond),
          ),
        ),
      if (_dragging != null)
        ...segmentDragOverlay(
          keys: keys, dragging: _dragging!, drop: drop!, pointerX: _dragX,
          x: _x, rowTop: pillTop, height: pillHeight,
        ),
    ]);
  }

  void _clearClip() => ref.read(selectedClipProvider.notifier).state = null;

  void _selectKey(Keyframe k) {
    _clearClip();
    ref.read(editHistoryProvider.notifier).breakStep();
    ref.read(segmentLoopProvider.notifier).stop();
    ref.read(sceneControllerProvider)?.pause();
    ref.read(selectedKeyframeProvider.notifier).state = k.id;
    ref.read(sceneControllerProvider)?.seek(k.time);
  }

  /// Tapping a move loops it; tapping the looping move again lets go of it.
  void _selectSegment(Keyframe end) {
    _clearClip();
    if (ref.read(segmentLoopProvider) == end.id) {
      ref.read(segmentLoopProvider.notifier).stop();
      ref.read(sceneControllerProvider)?.pause();
      ref.read(selectedKeyframeProvider.notifier).state = null;
      return;
    }
    ref.read(selectedKeyframeProvider.notifier).state = end.id;
    ref.read(segmentLoopProvider.notifier).loop(end.id);
  }

  void _retime(String id, double seconds) {
    final k = ref.read(timelineProvider).byId(id);
    if (k == null) return;
    final next = k.copyWith(time: math.max(0, k.time + seconds));
    ref.read(timelineProvider.notifier).update(next);
    ref.read(sceneControllerProvider)?.seek(next.time);
  }

  void _drop(int? drop) {
    final from = _dragging;
    setState(() => _dragging = null);
    if (from != null && drop != null) {
      ref.read(editHistoryProvider.notifier).breakStep();
      ref.read(timelineProvider.notifier).moveSegment(from, drop);
    }
  }
}
