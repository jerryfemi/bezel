import 'package:flutter/material.dart';

import 'track_style.dart';

/// Which part of a clip is being dragged.
enum ClipEdge { body, left, right }

/// One clip on a timeline row, CapCut style: drag the body to move it, drag
/// either edge to trim it. Handles show on hover and while selected.
/// Drags report the total distance since they began, so the row can work
/// from the clip's original start and end (and snap cleanly).
class ClipBlock extends StatefulWidget {
  const ClipBlock({
    super.key,
    required this.style,
    required this.selected,
    required this.child,
    required this.onSelect,
    required this.onDragStart,
    required this.onDrag,
    this.onDragEnd,
    this.onDoubleTap,
  });

  final TrackStyle style;
  final bool selected;
  final Widget child;
  final VoidCallback onSelect;
  final ValueChanged<ClipEdge> onDragStart;
  final void Function(ClipEdge edge, double totalDx) onDrag;
  final VoidCallback? onDragEnd;
  final VoidCallback? onDoubleTap;

  static const handleWidth = 9.0;

  @override
  State<ClipBlock> createState() => _ClipBlockState();
}

class _ClipBlockState extends State<ClipBlock> {
  bool _hover = false;
  double _dx = 0;

  Widget _drag(ClipEdge edge, MouseCursor cursor, Widget child) {
    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelect,
        onDoubleTap: edge == ClipEdge.body ? widget.onDoubleTap : null,
        onHorizontalDragStart: (_) {
          _dx = 0;
          widget.onDragStart(edge);
        },
        onHorizontalDragUpdate: (d) {
          _dx += d.delta.dx;
          widget.onDrag(edge, _dx);
        },
        onHorizontalDragEnd: (_) => widget.onDragEnd?.call(),
        onHorizontalDragCancel: () => widget.onDragEnd?.call(),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final showHandles = widget.selected || _hover;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: s.fill,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.selected ? Colors.white : s.edge.withValues(alpha: _hover ? 0.9 : 0.55),
            width: widget.selected ? 2 : 1,
          ),
        ),
        child: Stack(fit: StackFit.expand, children: [
          _drag(ClipEdge.body, SystemMouseCursors.grab, widget.child),
          Positioned(
            left: 0, top: 0, bottom: 0, width: ClipBlock.handleWidth,
            child: _drag(ClipEdge.left, SystemMouseCursors.resizeLeftRight,
                _Handle(visible: showHandles, selected: widget.selected)),
          ),
          Positioned(
            right: 0, top: 0, bottom: 0, width: ClipBlock.handleWidth,
            child: _drag(ClipEdge.right, SystemMouseCursors.resizeLeftRight,
                _Handle(visible: showHandles, selected: widget.selected)),
          ),
        ]),
      ),
    );
  }
}

/// The trim grip at each end: a light bar with a short dark notch.
class _Handle extends StatelessWidget {
  const _Handle({required this.visible, required this.selected});

  final bool visible;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: visible ? 1 : 0,
      child: Container(
        color: selected ? Colors.white : const Color(0xCCFFFFFF),
        alignment: Alignment.center,
        child: Container(
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C20),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
