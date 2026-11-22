import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The shape of the exported clip, and of the frame on the canvas.
enum FrameShape {
  landscape('16:9', 16 / 9, 'YouTube, portfolio, X'),
  square('1:1', 1, 'LinkedIn and X feeds'),
  portrait('4:5', 4 / 5, 'Instagram and LinkedIn'),
  vertical('9:16', 9 / 16, 'Reels, TikTok, Shorts');

  const FrameShape(this.label, this.aspect, this.usedFor);

  final String label;
  final double aspect;
  final String usedFor;
}

final frameShapeProvider = StateProvider<FrameShape>((ref) => FrameShape.landscape);
