import 'package:flutter/widgets.dart';

/// The grey checks shown behind a see-through background, as in image editors.
class Checkerboard extends StatelessWidget {
  const Checkerboard({super.key});

  @override
  Widget build(BuildContext context) =>
      const RepaintBoundary(child: CustomPaint(painter: _CheckerPainter()));
}

class _CheckerPainter extends CustomPainter {
  const _CheckerPainter();

  static const _cell = 12.0;
  static final _light = Paint()..color = const Color(0xFF3A3A40);
  static final _dark = Paint()..color = const Color(0xFF2A2A2F);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _dark);
    for (var y = 0.0; y < size.height; y += _cell) {
      final odd = (y / _cell).round().isOdd;
      for (var x = odd ? _cell : 0.0; x < size.width; x += _cell * 2) {
        canvas.drawRect(Rect.fromLTWH(x, y, _cell, _cell), _light);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter oldDelegate) => false;
}
