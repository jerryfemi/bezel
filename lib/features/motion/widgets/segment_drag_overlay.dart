import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../model/keyframe.dart';
import 'segment_pill.dart';

/// While a move is carried: a copy of its pill under the pointer, and a
/// marker where it will land. Returned as Stack children for the track.
List<Widget> segmentDragOverlay({
  required List<Keyframe> keys,
  required int dragging,
  required int drop,
  required double pointerX,
  required double Function(double seconds) x,
  required double rowTop,
}) {
  final width = x(keys[dragging].time) - x(keys[dragging - 1].time);
  final others = [for (var s = 1; s < keys.length; s++) if (s != dragging) s];
  final markerX = drop - 1 < others.length ? x(keys[others[drop - 1] - 1].time) : x(keys.last.time);
  return [
    Positioned(
      left: markerX - 1, top: rowTop - 2, width: 2, height: 32,
      child: const IgnorePointer(child: ColoredBox(color: BezelColors.accentLine)),
    ),
    Positioned(
      left: pointerX - width / 2, top: rowTop - 6, width: width, height: 20,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.9,
          child: SegmentPillFace(easing: keys[dragging].easing, selected: true),
        ),
      ),
    ),
  ];
}
