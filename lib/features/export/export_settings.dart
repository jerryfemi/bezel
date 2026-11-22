import 'dart:convert';

import '../editor/state/frame_shape.dart';

enum ExportFormat {
  mp4('MP4', 'Best for sharing anywhere'),
  webm('WebM', 'Smaller, for the web'),
  gif('GIF', 'Loops in READMEs and chats'),
  png('PNG', 'A still of the current frame');

  const ExportFormat(this.label, this.hint);

  final String label;
  final String hint;

  bool get isVideo => this == mp4 || this == webm;
}

/// Short side in pixels: 1080p, 1440p, 4K.
enum ExportQuality {
  hd(1080, '1080p'),
  qhd(1440, '1440p'),
  uhd(2160, '4K');

  const ExportQuality(this.shortSide, this.label);

  final int shortSide;
  final String label;
}

class ExportSettings {
  const ExportSettings({
    this.format = ExportFormat.mp4,
    this.quality = ExportQuality.hd,
    this.fps = 30,
  });

  final ExportFormat format;
  final ExportQuality quality;
  final int fps;

  /// GIFs are kept small; everything else follows the chosen quality.
  static const gifShortSide = 540;

  ExportSettings copyWith({ExportFormat? format, ExportQuality? quality, int? fps}) =>
      ExportSettings(
        format: format ?? this.format,
        quality: quality ?? this.quality,
        fps: fps ?? this.fps,
      );

  /// Pixel size for [shape]. Both sides even, as H.264 requires.
  (int, int) sizeFor(FrameShape shape) {
    final short = format == ExportFormat.gif ? gifShortSide : quality.shortSide;
    final long = (short * (shape.aspect >= 1 ? shape.aspect : 1 / shape.aspect)).round();
    int even(int v) => v.isEven ? v : v + 1;
    return shape.aspect >= 1 ? (even(long), short) : (short, even(long));
  }

  /// Rough file size for [seconds] of video, for the estimate in the sheet.
  double estimateMegabytes(FrameShape shape, double seconds) {
    final (w, h) = sizeFor(shape);
    if (format == ExportFormat.png) return w * h * 1.2 / 1e6;
    if (format == ExportFormat.gif) return w * h * 0.35 * 20 * seconds / 1e6;
    final bitrate = (w * h * fps * 0.15).clamp(0, 50e6);
    return bitrate * seconds / 8 / 1e6;
  }

  String toJson(FrameShape shape, String name) {
    final (w, h) = sizeFor(shape);
    return jsonEncode({'format': format.name, 'width': w, 'height': h, 'fps': fps, 'name': name});
  }
}
