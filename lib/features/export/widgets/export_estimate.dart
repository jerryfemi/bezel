import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../editor/state/frame_shape.dart';
import '../export_settings.dart';

/// Pixel size, length and an approximate file size.
class ExportEstimate extends StatelessWidget {
  const ExportEstimate({
    super.key,
    required this.settings,
    required this.shape,
    required this.seconds,
    required this.hasMotion,
  });

  final ExportSettings settings;
  final FrameShape shape;
  final double seconds;
  final bool hasMotion;

  @override
  Widget build(BuildContext context) {
    final (w, h) = settings.sizeFor(shape);
    final mb = settings.estimateMegabytes(shape, seconds);
    final length = settings.format == ExportFormat.png
        ? 'Still image'
        : hasMotion ? '${seconds.toStringAsFixed(1)}s clip' : '3s hold (no motion yet)';
    final size = mb < 1 ? '${(mb * 1000).round()} KB' : '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(BezelRadius.control),
      ),
      child: Row(children: [
        Text('$w × $h', style: BezelType.mono),
        const SizedBox(width: 10),
        Expanded(child: Text(length, style: BezelType.caption.copyWith(color: BezelColors.textSecondary))),
        Text('≈ $size', style: BezelType.caption.copyWith(color: BezelColors.textSecondary)),
      ]),
    );
  }
}
