import 'dart:math' as math;

import 'clips.dart';

/// Shortest a clip can be trimmed to, in seconds.
const minClipLength = 0.2;

/// The free space around clip [id] on its track: from the end of the clip
/// before it to the start of the clip after it. Clips never overlap.
({double before, double after}) neighbours(List<TimedClip> track, String id) {
  var before = 0.0;
  var after = double.infinity;
  final i = track.indexWhere((c) => c.id == id);
  if (i > 0) before = track[i - 1].end;
  if (i >= 0 && i + 1 < track.length) after = track[i + 1].start;
  return (before: before, after: after);
}

/// Where a clip can start if dragged to [wanted]: it stays in its gap.
double clampStart(List<TimedClip> track, TimedClip clip, double wanted) {
  final room = neighbours(track, clip.id);
  final latest = room.after - clip.length;
  return math.max(room.before, math.min(wanted, latest));
}

/// Left-edge trim. [sourceLength] is the file's length (null for images,
/// which can be any length). Returns the new start and the new in-point.
({double start, double inPoint}) trimStart(
  List<TimedClip> track,
  TimedClip clip,
  double wanted, {
  double inPoint = 0,
  double? sourceLength,
}) {
  final room = neighbours(track, clip.id);
  var earliest = room.before;
  if (sourceLength != null) earliest = math.max(earliest, clip.start - inPoint);
  final start = math.max(earliest, math.min(wanted, clip.end - minClipLength));
  final nextIn = sourceLength == null ? 0.0 : math.max(0.0, inPoint + (start - clip.start));
  return (start: start, inPoint: nextIn);
}

/// Right-edge trim: the new end.
double trimEnd(
  List<TimedClip> track,
  TimedClip clip,
  double wanted, {
  double inPoint = 0,
  double? sourceLength,
}) {
  final room = neighbours(track, clip.id);
  var latest = room.after;
  if (sourceLength != null) latest = math.min(latest, clip.start + sourceLength - inPoint);
  return math.min(latest, math.max(wanted, clip.start + minClipLength));
}

/// True if [t] is far enough inside [clip] to split it there.
bool canSplit(TimedClip clip, double t) =>
    t > clip.start + minClipLength * 0.5 && t < clip.end - minClipLength * 0.5;

/// Pulls [t] onto the nearest of [points] when within [tolerance] seconds.
double snapTo(double t, Iterable<double> points, double tolerance) {
  var best = t;
  var bestGap = tolerance;
  for (final p in points) {
    final gap = (p - t).abs();
    if (gap < bestGap) {
      best = p;
      bestGap = gap;
    }
  }
  return best;
}

/// The first free gap on [track] at or after [from] that fits [length]
/// (used when adding a clip at the playhead).
double firstFreeStart(List<TimedClip> track, double from, double length) {
  var t = from;
  for (final c in track) {
    if (c.end <= t) continue;
    if (c.start >= t + length) break;
    t = c.end;
  }
  return t;
}
