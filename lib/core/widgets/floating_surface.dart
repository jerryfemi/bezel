import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_metrics.dart';

/// The material every floating piece of chrome is made of.
/// Larger surfaces ([elevated]) get a deeper shadow.
class FloatingSurface extends StatelessWidget {
  const FloatingSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = BezelRadius.dock,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: elevated ? BezelColors.surfaceRaised : BezelColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: elevated ? BezelColors.strokeStrong : BezelColors.stroke),
        boxShadow: elevated
            ? const [BoxShadow(color: Color(0x80000000), blurRadius: 60, offset: Offset(0, 24))]
            : null,
      ),
      child: child,
    );
  }
}
