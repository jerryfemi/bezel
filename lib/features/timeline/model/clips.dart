import '../../scene3d/scene_specs.dart';

/// The rows of the timeline, top to bottom.
enum TrackKind { caption, screen, motion, audio }

/// Shared by every clip: where it sits on the timeline, in seconds.
abstract class TimedClip {
  String get id;
  double get start;
  double get end;
  double get length => end - start;
  bool covers(double t) => t >= start && t < end;
}

/// A caption shown from [start] to [end].
class CaptionClip extends TimedClip {
  CaptionClip({required this.id, required this.start, required this.end, required this.spec});

  @override
  final String id;
  @override
  final double start;
  @override
  final double end;
  final CaptionSpec spec;

  CaptionClip copyWith({String? id, double? start, double? end, CaptionSpec? spec}) => CaptionClip(
      id: id ?? this.id, start: start ?? this.start, end: end ?? this.end, spec: spec ?? this.spec);

  Map<String, Object?> toMap() => {'id': id, 'start': start, 'end': end, ...spec.toMap()};

  factory CaptionClip.fromMap(Map<String, dynamic> m) => CaptionClip(
        id: m['id'] as String,
        start: (m['start'] as num).toDouble(),
        end: (m['end'] as num).toDouble(),
        spec: CaptionSpec.fromMap(m),
      );
}

/// A stretch of an image, video or sound file. [inPoint] is where in the
/// file the clip starts (trimming the left edge moves it).
class MediaClip extends TimedClip {
  MediaClip({
    required this.id,
    required this.start,
    required this.end,
    required this.assetId,
    this.inPoint = 0,
    this.volume = 1,
    this.muted = false,
    this.fadeIn = 0,
    this.fadeOut = 0,
  });

  @override
  final String id;
  @override
  final double start;
  @override
  final double end;
  final String assetId;
  final double inPoint;

  /// 0 to 1. Kept while [muted], so unmuting brings the same level back.
  final double volume;
  final bool muted;

  /// Seconds the sound takes to rise at the start and die away at the end.
  final double fadeIn;
  final double fadeOut;

  MediaClip copyWith({
    String? id,
    double? start,
    double? end,
    String? assetId,
    double? inPoint,
    double? volume,
    bool? muted,
    double? fadeIn,
    double? fadeOut,
  }) =>
      MediaClip(
        id: id ?? this.id,
        start: start ?? this.start,
        end: end ?? this.end,
        assetId: assetId ?? this.assetId,
        inPoint: inPoint ?? this.inPoint,
        volume: volume ?? this.volume,
        muted: muted ?? this.muted,
        fadeIn: fadeIn ?? this.fadeIn,
        fadeOut: fadeOut ?? this.fadeOut,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'start': start,
        'end': end,
        'assetId': assetId,
        'inPoint': inPoint,
        'volume': volume,
        'muted': muted,
        'fadeIn': fadeIn,
        'fadeOut': fadeOut,
      };

  factory MediaClip.fromMap(Map<String, dynamic> m) => MediaClip(
        id: m['id'] as String,
        start: (m['start'] as num).toDouble(),
        end: (m['end'] as num).toDouble(),
        assetId: m['assetId'] as String,
        inPoint: (m['inPoint'] as num?)?.toDouble() ?? 0,
        volume: (m['volume'] as num?)?.toDouble() ?? 1,
        muted: m['muted'] as bool? ?? false,
        fadeIn: (m['fadeIn'] as num?)?.toDouble() ?? 0,
        fadeOut: (m['fadeOut'] as num?)?.toDouble() ?? 0,
      );
}

/// A clip on a given track, as the timeline's selection.
class ClipRef {
  const ClipRef(this.track, this.id);

  final TrackKind track;
  final String id;

  @override
  bool operator ==(Object other) => other is ClipRef && other.track == track && other.id == id;

  @override
  int get hashCode => Object.hash(track, id);
}
