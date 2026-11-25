import 'dart:typed_data';

enum AssetKind { image, video, audio }

/// A file the user added (screenshot, screen recording or music). Clips on
/// the timeline point at an asset by [id]; the bytes are kept so the project
/// can be saved, and [url] is a blob: URL the browser plays it from.
class MediaAsset {
  const MediaAsset({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.kind,
    required this.bytes,
    required this.url,
    this.duration,
    this.filmstrip = const [],
    this.peaks = const [],
  });

  final String id;
  final String name;
  final String mimeType;
  final AssetKind kind;
  final Uint8List bytes;
  final String url;

  /// Seconds of footage or sound; null for images (they last as long as you like).
  final double? duration;

  /// Small frame thumbnails (data URLs) for the screen track, left to right.
  final List<String> filmstrip;

  /// Loudness from 0 to 1 across the file, for drawing a waveform.
  final List<double> peaks;

  bool get isVideo => kind == AssetKind.video;
  bool get hasSound => kind != AssetKind.image;

  MediaAsset copyWith({double? duration, List<String>? filmstrip, List<double>? peaks}) => MediaAsset(
        id: id,
        name: name,
        mimeType: mimeType,
        kind: kind,
        bytes: bytes,
        url: url,
        duration: duration ?? this.duration,
        filmstrip: filmstrip ?? this.filmstrip,
        peaks: peaks ?? this.peaks,
      );

  /// What is saved alongside the bytes.
  Map<String, Object?> toMap() =>
      {'id': id, 'name': name, 'mime': mimeType, 'kind': kind.name, 'duration': duration};

  static AssetKind kindFor(String mimeType) => mimeType.startsWith('video/')
      ? AssetKind.video
      : mimeType.startsWith('audio/')
          ? AssetKind.audio
          : AssetKind.image;
}
