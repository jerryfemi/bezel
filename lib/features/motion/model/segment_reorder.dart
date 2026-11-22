import 'keyframe.dart';

/// Moves one segment of the clip to a new place.
///
/// A segment is "move to keyframe i's pose, over (t[i] − t[i−1]) seconds,
/// with keyframe i's easing", so segment i is identified by its end keyframe
/// index i (1..n−1). The first keyframe is the starting pose and never moves.
/// [toIndex] is the segment index the moved segment should end up at.
/// Times are rebuilt so every segment keeps its own duration.
List<Keyframe> reorderSegments(List<Keyframe> keys, int fromIndex, int toIndex) {
  if (keys.length < 3 || fromIndex == toIndex) return keys;
  final start = keys.first;
  final durations = [for (var i = 1; i < keys.length; i++) keys[i].time - keys[i - 1].time];
  final segments = [for (var i = 1; i < keys.length; i++) (key: keys[i], length: durations[i - 1])];

  final moved = segments.removeAt(fromIndex - 1);
  segments.insert((toIndex - 1).clamp(0, segments.length), moved);

  var t = start.time;
  return [
    start,
    for (final s in segments) s.key.copyWith(time: t += s.length),
  ];
}
