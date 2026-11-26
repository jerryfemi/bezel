import 'package:flutter/widgets.dart';

/// The split mark: two brackets facing apart, "][", like a clip cut open.
class SplitGlyph extends StatelessWidget {
  const SplitGlyph({super.key, required this.color, this.size = 18});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _SplitPainter(color));
}

class _SplitPainter extends CustomPainter {
  _SplitPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w / 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final top = h * 0.2;
    final bottom = h * 0.8;
    final arm = w * 0.16;
    // "]" on the left, "[" on the right, with a gap between them.
    final left = Path()
      ..moveTo(w * 0.42 - arm, top)
      ..lineTo(w * 0.42, top)
      ..lineTo(w * 0.42, bottom)
      ..lineTo(w * 0.42 - arm, bottom);
    final right = Path()
      ..moveTo(w * 0.58 + arm, top)
      ..lineTo(w * 0.58, top)
      ..lineTo(w * 0.58, bottom)
      ..lineTo(w * 0.58 + arm, bottom);
    canvas
      ..drawPath(left, paint)
      ..drawPath(right, paint);
  }

  @override
  bool shouldRepaint(_SplitPainter old) => old.color != color;
}
