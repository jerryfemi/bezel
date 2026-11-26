import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/bezel_colors.dart';

/// The seam between two moves, where a keyframe sits. Click it to edit that
/// keyframe's pose; drag it sideways to retime it. Shows a line on hover.
class KeyEdge extends StatefulWidget {
  const KeyEdge({super.key, required this.selected, required this.onTap, required this.onDrag});

  static const hitWidth = 12.0;

  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<double> onDrag;

  @override
  State<KeyEdge> createState() => _KeyEdgeState();
}

class _KeyEdgeState extends State<KeyEdge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final show = _hover || widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        onHorizontalDragUpdate: (d) => widget.onDrag(d.delta.dx),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: show ? 3 : 0,
            decoration: BoxDecoration(
              color: widget.selected ? Colors.white : BezelColors.accentLine,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
