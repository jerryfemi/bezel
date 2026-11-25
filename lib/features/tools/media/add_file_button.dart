import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';

/// The dashed "add a file" button at the top of the Media and Audio panels.
class AddFileButton extends StatelessWidget {
  const AddFileButton({super.key, required this.label, required this.onTap, this.busy = false});

  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: busy ? null : onTap,
      label: label,
      pressedScale: 0.98,
      child: CustomPaint(
        painter: const _DashedBorder(),
        child: SizedBox(
          height: 38,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(busy ? Icons.hourglass_empty : Icons.add, size: 15, color: BezelColors.textPrimary),
            const SizedBox(width: 6),
            Text(busy ? 'Adding…' : label, style: BezelType.label),
          ]),
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder();

  static final _paint = Paint()
    ..color = BezelColors.strokeStrong
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75), const Radius.circular(9)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 9) {
        canvas.drawPath(metric.extractPath(d, d + 5), _paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) => false;
}
