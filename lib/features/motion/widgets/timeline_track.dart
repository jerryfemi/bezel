import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../editor/state/scene_provider.dart';
import '../model/keyframe.dart';
import '../model/motion_easing.dart';
import '../state/selected_keyframe_provider.dart';
import '../state/timeline_provider.dart';
import 'keyframe_diamond.dart';
import 'timeline_painters.dart';

/// Ruler (click or drag to scrub), the keyframes with the moves between
/// them, and the playhead.
class TimelineTrack extends ConsumerWidget {
  const TimelineTrack({super.key});

  static const _rulerHeight = 24.0;
  static const _rowTop = 34.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    final selected = ref.watch(selectedKeyframeProvider);
    final scene = ref.watch(sceneControllerProvider);
    final span = math.max(timeline.duration + 1, 5.0);

    return LayoutBuilder(builder: (context, box) {
      final pps = box.maxWidth / span;
      double x(double t) => t * pps;
      void seek(double dx) => scene?.seek(dx / pps);
      final keys = timeline.keyframes;

      return Stack(clipBehavior: Clip.none, children: [
        Positioned(
          left: 0, right: 0, top: 0, height: _rulerHeight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => seek(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => seek(d.localPosition.dx),
            child: CustomPaint(painter: RulerPainter(span: span)),
          ),
        ),
        for (var i = 1; i < keys.length; i++)
          Positioned(
            left: x(keys[i - 1].time), width: math.max(0, x(keys[i].time) - x(keys[i - 1].time)),
            top: _rowTop + 4, height: 20,
            child: _Segment(easing: keys[i].easing),
          ),
        for (final k in keys)
          Positioned(
            left: x(k.time) - KeyframeDiamond.hitSize / 2, top: _rowTop,
            child: KeyframeDiamond(
              selected: k.id == selected,
              onTap: () => _select(ref, k),
              onDrag: (dx) => _drag(ref, k.id, dx / pps),
            ),
          ),
        if (scene != null)
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<double>(
                valueListenable: scene.time,
                builder: (_, t, __) => CustomPaint(painter: PlayheadPainter(x(t))),
              ),
            ),
          ),
      ]);
    });
  }

  void _select(WidgetRef ref, Keyframe k) {
    ref.read(selectedKeyframeProvider.notifier).state = k.id;
    ref.read(sceneControllerProvider)?.seek(k.time);
  }

  void _drag(WidgetRef ref, String id, double seconds) {
    final k = ref.read(timelineProvider).byId(id);
    if (k == null) return;
    final next = k.copyWith(time: math.max(0, k.time + seconds));
    ref.read(timelineProvider.notifier).update(next);
    ref.read(sceneControllerProvider)?.seek(next.time);
  }
}

/// The move between two keyframes, labelled with its easing.
class _Segment extends StatelessWidget {
  const _Segment({required this.easing});

  final MotionEasing easing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BezelColors.accentSoft,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(easing.kind.name, style: BezelType.caption, overflow: TextOverflow.clip, maxLines: 1),
    );
  }
}
