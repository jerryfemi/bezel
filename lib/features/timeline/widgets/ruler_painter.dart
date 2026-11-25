import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';

/// Time marks along the top of the timeline. The spacing adapts to the zoom
/// so labels never crowd: whole seconds when zoomed in, bigger steps out.
class RulerPainter extends CustomPainter {
  RulerPainter({required this.pixelsPerSecond, required this.length});

  final double pixelsPerSecond;

  /// The finished video's length; the ruler is brighter up to it.
  final double length;

  static final _major = Paint()..color = BezelColors.strokeStrong;
  static final _minor = Paint()..color = BezelColors.stroke;
  static const _steps = [0.5, 1.0, 2.0, 5.0, 10.0, 15.0, 30.0, 60.0, 120.0];

  @override
  void paint(Canvas canvas, Size size) {
    final pps = pixelsPerSecond;
    final major = _steps.firstWhere((s) => s * pps >= 64, orElse: () => _steps.last);
    final minor = major / 5;
    final end = size.width / pps;
    if (minor * pps >= 6) {
      for (var t = 0.0; t <= end; t += minor) {
        final x = t * pps;
        canvas.drawLine(Offset(x, size.height - 4), Offset(x, size.height), _minor);
      }
    }
    for (var t = 0.0; t <= end; t += major) {
      final x = t * pps;
      canvas.drawLine(Offset(x, size.height - 9), Offset(x, size.height), _major);
      final label = TextPainter(
        text: TextSpan(
          text: _label(t),
          style: BezelType.caption.copyWith(
            fontSize: 10,
            color: t <= length + 1e-6 ? BezelColors.textSecondary : BezelColors.textTertiary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(x + 3, 2));
      label.dispose();
    }
  }

  static String _label(double t) {
    final whole = t.round();
    if ((t - whole).abs() > 1e-6) return '${t.toStringAsFixed(1)}s';
    final m = whole ~/ 60;
    final s = whole % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(RulerPainter old) =>
      old.pixelsPerSecond != pixelsPerSecond || old.length != length;
}

/// The playhead: a line through every track with a grip on the ruler.
class PlayheadPainter extends CustomPainter {
  PlayheadPainter(this.x, {required this.rulerHeight});

  final double x;
  final double rulerHeight;

  static final _line = Paint()
    ..color = Colors.white
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(x, rulerHeight - 6), Offset(x, size.height), _line);
    final grip = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, rulerHeight - 9), width: 11, height: 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(grip, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(PlayheadPainter old) => old.x != x;
}

/// Shades everything after the end of the video, with a marker at the end.
class EndMarkerPainter extends CustomPainter {
  EndMarkerPainter(this.x);

  final double x;

  @override
  void paint(Canvas canvas, Size size) {
    if (x >= size.width) return;
    canvas.drawRect(
      Rect.fromLTRB(x, 0, size.width, size.height),
      Paint()..color = const Color(0x55000000),
    );
    final dash = Paint()
      ..color = BezelColors.textTertiary
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 6) {
      canvas.drawLine(Offset(x, y), Offset(x, y + 3), dash);
    }
  }

  @override
  bool shouldRepaint(EndMarkerPainter old) => old.x != x;
}
