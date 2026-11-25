import 'dart:convert';
import 'dart:math' as math;

import 'clips.dart';

/// Every clip on the caption, screen and audio tracks (motion lives in
/// `MotionTimeline`). Each list is kept in time order without overlaps.
class Tracks {
  const Tracks({this.captions = const [], this.screens = const [], this.audio = const []});

  final List<CaptionClip> captions;
  final List<MediaClip> screens;
  final List<MediaClip> audio;

  bool get isEmpty => captions.isEmpty && screens.isEmpty && audio.isEmpty;

  /// Where the last clip on any of these tracks ends.
  double get end => [
        for (final c in captions) c.end,
        for (final c in screens) c.end,
        for (final c in audio) c.end,
      ].fold(0.0, math.max);

  List<TimedClip> on(TrackKind track) => switch (track) {
        TrackKind.caption => captions,
        TrackKind.screen => screens,
        TrackKind.audio => audio,
        TrackKind.motion => const [],
      };

  TimedClip? find(ClipRef? ref) {
    if (ref == null) return null;
    for (final c in on(ref.track)) {
      if (c.id == ref.id) return c;
    }
    return null;
  }

  Tracks copyWith({List<CaptionClip>? captions, List<MediaClip>? screens, List<MediaClip>? audio}) =>
      Tracks(
        captions: captions == null ? this.captions : _sorted(captions),
        screens: screens == null ? this.screens : _sorted(screens),
        audio: audio == null ? this.audio : _sorted(audio),
      );

  static List<T> _sorted<T extends TimedClip>(List<T> clips) =>
      [...clips]..sort((a, b) => a.start.compareTo(b.start));

  Map<String, Object?> toMap() => {
        'captions': [for (final c in captions) c.toMap()],
        'screens': [for (final c in screens) c.toMap()],
        'audio': [for (final c in audio) c.toMap()],
      };

  String toJson() => jsonEncode(toMap());

  factory Tracks.fromMap(Map<String, dynamic>? m) {
    List<Map<String, dynamic>> list(String key) =>
        [for (final e in (m?[key] as List?) ?? const []) (e as Map).cast<String, dynamic>()];
    return Tracks(
      captions: _sorted([for (final e in list('captions')) CaptionClip.fromMap(e)]),
      screens: _sorted([for (final e in list('screens')) MediaClip.fromMap(e)]),
      audio: _sorted([for (final e in list('audio')) MediaClip.fromMap(e)]),
    );
  }
}

/// The finished video's length: the end of the last clip or keyframe.
/// A project with neither is a still and exports as a short hold.
double clipLength(Tracks tracks, double motionEnd) => math.max(tracks.end, motionEnd);

/// Length used for video export of a still project.
const stillSeconds = 3.0;
