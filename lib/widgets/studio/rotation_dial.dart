import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class RotationDial extends ConsumerStatefulWidget {
  const RotationDial({super.key});

  @override
  ConsumerState<RotationDial> createState() => _RotationDialState();
}

class _RotationDialState extends ConsumerState<RotationDial> {
  // Presets in radians (X, Y)
  static const double _snapThreshold = 0.087; // ~5 degrees

  final List<_Preset> _presets = [
    const _Preset('Front', 0.0, 0.0),
    const _Preset('3/4 Left', 0.0, -0.523), // -30 degrees
    const _Preset('3/4 Right', 0.0, 0.523), // 30 degrees
  ];

  void _snapToPresetIfNeeded(double currentX, double currentY) {
    for (final preset in _presets) {
      if ((currentX - preset.x).abs() < _snapThreshold &&
          (currentY - preset.y).abs() < _snapThreshold) {
        // Snap!
        ref.read(mockupProjectProvider.notifier).setRotation(preset.x, preset.y, 0.0);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(mockupProjectProvider);
    final xDeg = (project.rotationX * 57.2958).round();
    final yDeg = (project.rotationY * 57.2958).round();

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryText.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: GestureDetector(
        onPanUpdate: (details) {
          ref.read(mockupProjectProvider.notifier).updateRotation(
                -details.delta.dy * 0.01,
                details.delta.dx * 0.01,
                0,
              );
        },
        onPanEnd: (_) {
          final p = ref.read(mockupProjectProvider);
          _snapToPresetIfNeeded(p.rotationX, p.rotationY);
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grid lines for visual tech feel
              CustomPaint(
                size: const Size(140, 140),
                painter: _DialPainter(
                  rotationX: project.rotationX,
                  rotationY: project.rotationY,
                ),
              ),
              
              // Text readout
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('X: $xDeg°', style: AppTypography.technical),
                  const SizedBox(height: 2),
                  Text('Y: $yDeg°', style: AppTypography.technical),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preset {
  final String label;
  final double x;
  final double y;
  const _Preset(this.label, this.x, this.y);
}

class _DialPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;

  _DialPainter({required this.rotationX, required this.rotationY});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw crosshair
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(center.dx, 10), Offset(center.dx, size.height - 10), paint);
    canvas.drawLine(Offset(10, center.dy), Offset(size.width - 10, center.dy), paint);

    // Draw active indicator dot based on rotation
    // Maps rotation (-pi to pi) roughly to the dial surface
    final maxVisRot = math.pi / 2; // 90 degrees
    
    double mappedX = (rotationY / maxVisRot).clamp(-1.0, 1.0);
    double mappedY = (-rotationX / maxVisRot).clamp(-1.0, 1.0);

    // Give it a circular bound
    final distance = math.sqrt(mappedX * mappedX + mappedY * mappedY);
    if (distance > 1.0) {
      mappedX /= distance;
      mappedY /= distance;
    }

    final dotPos = Offset(
      center.dx + (mappedX * (radius - 12)),
      center.dy + (mappedY * (radius - 12)),
    );

    final dotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
      
    // Glow
    final glowPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(dotPos, 8, glowPaint);
    canvas.drawCircle(dotPos, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX || oldDelegate.rotationY != rotationY;
  }
}
