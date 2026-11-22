import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';

/// Second marks along the top of the timeline.
class RulerPainter extends CustomPainter {
  RulerPainter({required this.span});

  final double span;
  static final _tick = Paint()..color = BezelColors.strokeStrong;

  @override
  void paint(Canvas canvas, Size size) {
    final pps = size.width / span;
    for (var s = 0; s <= span; s++) {
      final x = s * pps;
      canvas.drawLine(Offset(x, size.height - 6), Offset(x, size.height), _tick);
      final label = TextPainter(
        text: TextSpan(text: '${s}s', style: BezelType.caption.copyWith(color: BezelColors.textTertiary)),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, Offset(x + 3, 0));
      label.dispose();
    }
  }

  @override
  bool shouldRepaint(RulerPainter old) => old.span != span;
}

/// The vertical line at the current playback time.
class PlayheadPainter extends CustomPainter {
  PlayheadPainter(this.x);

  final double x;
  static final _paint = Paint()
    ..color = BezelColors.textPrimary
    ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _paint);

  @override
  bool shouldRepaint(PlayheadPainter old) => old.x != x;
}
