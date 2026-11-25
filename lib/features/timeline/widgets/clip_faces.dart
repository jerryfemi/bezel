import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../app/theme/bezel_type.dart';
import '../model/clips.dart';
import '../model/media_asset.dart';

/// Inside a caption clip: its headline.
class CaptionFace extends StatelessWidget {
  const CaptionFace({super.key, required this.clip});

  final CaptionClip clip;

  @override
  Widget build(BuildContext context) {
    final text = clip.spec.headline.trim().isEmpty ? clip.spec.subtitle : clip.spec.headline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text.isEmpty ? 'Caption' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BezelType.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Inside a screen clip: frames from the file laid end to end, so you can
/// see what plays where, with the file name on top.
class FilmstripFace extends StatelessWidget {
  const FilmstripFace({super.key, required this.clip, required this.asset, required this.pixelsPerSecond});

  final MediaClip clip;
  final MediaAsset? asset;
  final double pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    final frames = asset?.filmstrip ?? const [];
    return Stack(fit: StackFit.expand, children: [
      if (frames.isNotEmpty)
        LayoutBuilder(builder: (context, box) {
          final tileHeight = box.maxHeight;
          final first = _bytes(frames.first);
          const tileWidth = 30.0; // narrow tiles read well for portrait screens
          final count = math.max(1, (box.maxWidth / tileWidth).ceil());
          final duration = asset?.duration;
          return OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: double.infinity,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < count; i++)
              SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: Image.memory(
                  duration == null || frames.length == 1
                      ? first
                      : _bytes(frames[_frameAt(i, tileWidth, duration, frames.length)]),
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ]),
          );
        }),
      _NameTag(asset?.name ?? 'Media'),
    ]);
  }

  /// Which thumbnail shows the moment under tile [i].
  int _frameAt(int i, double tileWidth, double duration, int count) {
    final t = clip.inPoint + (i + 0.5) * tileWidth / pixelsPerSecond;
    return (t / duration * count).floor().clamp(0, count - 1);
  }
}

/// Inside an audio clip: the waveform of the part that plays, and the name.
class WaveformFace extends StatelessWidget {
  const WaveformFace({super.key, required this.clip, required this.asset, required this.color});

  final MediaClip clip;
  final MediaAsset? asset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final peaks = asset?.peaks ?? const <double>[];
    final duration = asset?.duration;
    return Stack(fit: StackFit.expand, children: [
      if (peaks.isNotEmpty && duration != null && duration > 0)
        CustomPaint(
          painter: _WavePainter(
            peaks: peaks,
            from: clip.inPoint / duration,
            to: (clip.inPoint + clip.length) / duration,
            color: color,
          ),
        ),
      _NameTag(asset?.name ?? 'Audio'),
    ]);
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.peaks, required this.from, required this.to, required this.color});

  final List<double> peaks;
  final double from;
  final double to;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..strokeWidth = 1.5;
    final mid = size.height * 0.58;
    for (var x = 0.0; x < size.width; x += 3) {
      final f = from + (to - from) * (x / size.width);
      final i = (f * peaks.length).floor().clamp(0, peaks.length - 1);
      final h = math.max(1.0, peaks[i] * size.height * 0.38);
      canvas.drawLine(Offset(x, mid - h), Offset(x, mid + h), paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.from != from || old.to != to || old.peaks != peaks || old.color != color;
}

class _NameTag extends StatelessWidget {
  const _NameTag(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 3, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: const Color(0x99000000),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BezelType.caption.copyWith(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}

/// Thumbnails arrive as data URLs; decode each once.
final _cache = <String, Uint8List>{};

Uint8List _bytes(String dataUrl) =>
    _cache.putIfAbsent(dataUrl, () => UriData.parse(dataUrl).contentAsBytes());
