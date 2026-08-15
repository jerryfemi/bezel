import 'package:flutter/material.dart';

class CheckerboardPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double squareSize;

  CheckerboardPainter({
    this.color1 = const Color(0xFF1E1E1E),
    this.color2 = const Color(0xFF262626),
    this.squareSize = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = color1;
    final paint2 = Paint()..color = color2;

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isEven =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isEven ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
