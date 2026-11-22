import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';

/// A keyframe marker. Tap to select; drag sideways to move it in time.
class KeyframeDiamond extends StatelessWidget {
  const KeyframeDiamond({
    super.key,
    required this.selected,
    required this.onTap,
    required this.onDrag,
  });

  static const hitSize = 28.0;

  final bool selected;
  final VoidCallback onTap;

  /// Horizontal drag distance in logical pixels since the last update.
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onHorizontalDragStart: (_) => onTap(),
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: SizedBox.square(
          dimension: hitSize,
          child: Center(
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: selected ? BezelColors.textPrimary : BezelColors.accentLine,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: selected
                      ? const [BoxShadow(color: Color(0x998FB0FF), spreadRadius: 3)]
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
