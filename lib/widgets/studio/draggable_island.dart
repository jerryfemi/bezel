import 'package:flutter/material.dart';

class DraggableIsland extends StatefulWidget {
  final Widget child;
  final Offset initialOffset;

  const DraggableIsland({
    super.key,
    required this.child,
    this.initialOffset = Offset.zero,
  });

  @override
  State<DraggableIsland> createState() => _DraggableIslandState();
}

class _DraggableIslandState extends State<DraggableIsland> {
  late Offset _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: widget.child,
      ),
    );
  }
}
