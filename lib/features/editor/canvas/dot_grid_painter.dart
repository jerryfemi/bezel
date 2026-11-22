import 'package:flutter/rendering.dart';

import '../../../app/theme/bezel_colors.dart';

/// The faint dot grid behind the scene frame.
class DotGridPainter extends CustomPainter {
  const DotGridPainter();

  static const _spacing = 20.0;
  static final _paint = Paint()..color = BezelColors.dotGrid;

  @override
  void paint(Canvas canvas, Size size) {
    for (var y = _spacing / 2; y < size.height; y += _spacing) {
      for (var x = _spacing / 2; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), 1, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter oldDelegate) => false;
}
