import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../model/keyframe.dart';
import '../state/segment_loop_provider.dart';
import '../state/selected_keyframe_provider.dart';
import '../state/timeline_provider.dart';
import 'keyframe_diamond.dart';
import 'segment_drag.dart';
import 'segment_drag_overlay.dart';
import 'segment_pill.dart';
import 'timeline_painters.dart';

/// Ruler (click or drag to scrub), keyframes, the moves between them, and
/// the playhead. [pixelsPerSecond] comes from the timeline's zoom.
class TimelineTrack extends ConsumerStatefulWidget {
  const TimelineTrack({super.key, required this.pixelsPerSecond, required this.span});

  final double pixelsPerSecond;
  final double span;

  @override
  ConsumerState<TimelineTrack> createState() => _TimelineTrackState();
}

class _TimelineTrackState extends ConsumerState<TimelineTrack> {
  static const _rulerHeight = 24.0;
  static const _rowTop = 34.0;

  int? _dragging; // segment index being carried
  double _dragX = 0;

  double _x(double t) => t * widget.pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    final keys = ref.watch(timelineProvider).keyframes;
    final selected = ref.watch(selectedKeyframeProvider);
    final scene = ref.watch(sceneControllerProvider);
    final mids = [for (var i = 1; i < keys.length; i++) _x((keys[i - 1].time + keys[i].time) / 2)];
    final drop = _dragging == null ? null : dropIndexFor(_dragX, _dragging!, mids);

    return Stack(clipBehavior: Clip.none, children: [
      // Empty space under the moves: tapping it deselects.
      Positioned.fill(
        top: _rulerHeight,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _deselect),
      ),
      Positioned(
        left: 0, right: 0, top: 0, height: _rulerHeight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => scene?.seek(d.localPosition.dx / widget.pixelsPerSecond),
          onHorizontalDragUpdate: (d) => scene?.seek(d.localPosition.dx / widget.pixelsPerSecond),
          child: CustomPaint(painter: RulerPainter(span: widget.span)),
        ),
      ),
      for (var i = 1; i < keys.length; i++)
        Positioned(
          left: _x(keys[i - 1].time), width: math.max(0, _x(keys[i].time) - _x(keys[i - 1].time)),
          top: _rowTop + 4, height: 20,
          child: SegmentPill(
            easing: keys[i].easing,
            selected: keys[i].id == selected,
            ghost: _dragging == i,
            onTap: () => _selectSegment(keys[i]),
            onDragStart: (d) => setState(() { _dragging = i; _dragX = _x(keys[i - 1].time) + d.localPosition.dx; }),
            onDragUpdate: (d) => setState(() => _dragX += d.delta.dx),
            onDragEnd: () => _drop(drop),
          ),
        ),
      for (final k in keys)
        Positioned(
          left: _x(k.time) - KeyframeDiamond.hitSize / 2, top: _rowTop,
          child: KeyframeDiamond(
            selected: k.id == selected,
            onTap: () => _selectKey(k),
            onDrag: (dx) => _retime(k.id, dx / widget.pixelsPerSecond),
          ),
        ),
      if (_dragging != null)
        ...segmentDragOverlay(
          keys: keys, dragging: _dragging!, drop: drop!, pointerX: _dragX,
          x: _x, rowTop: _rowTop,
        ),
      if (scene != null)
        Positioned.fill(
          child: IgnorePointer(
            child: ValueListenableBuilder<double>(
              valueListenable: scene.time,
              builder: (_, t, __) => CustomPaint(painter: PlayheadPainter(_x(t))),
            ),
          ),
        ),
    ]);
  }

  void _selectKey(Keyframe k) {
    ref.read(segmentLoopProvider.notifier).stop();
    ref.read(sceneControllerProvider)?.pause();
    ref.read(selectedKeyframeProvider.notifier).state = k.id;
    ref.read(sceneControllerProvider)?.seek(k.time);
  }

  /// Tapping a move loops it; tapping the looping move again lets go of it.
  void _selectSegment(Keyframe end) {
    if (ref.read(segmentLoopProvider) == end.id) return _deselect();
    ref.read(selectedKeyframeProvider.notifier).state = end.id;
    ref.read(segmentLoopProvider.notifier).loop(end.id);
  }

  /// Clears the selection and goes back to the whole clip (paused where it is).
  void _deselect() {
    final looping = ref.read(segmentLoopProvider) != null;
    ref.read(segmentLoopProvider.notifier).stop();
    if (looping) ref.read(sceneControllerProvider)?.pause();
    ref.read(selectedKeyframeProvider.notifier).state = null;
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
    if (from != null && drop != null) ref.read(timelineProvider.notifier).moveSegment(from, drop);
  }
}
