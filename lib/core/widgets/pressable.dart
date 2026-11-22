import 'package:flutter/material.dart';

import '../../app/theme/bezel_motion.dart';

/// Tap target that responds on press-down (scales slightly), not on release.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    required this.onTap,
    this.label,
    this.selected = false,
    this.pressedScale = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? label;
  final bool selected;
  final double pressedScale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.label,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapUp: enabled ? (_) => _set(false) : null,
          onTapCancel: () => _set(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _down ? widget.pressedScale : 1,
            duration: BezelMotion.of(context, BezelMotion.press),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: enabled ? 1 : 0.45,
              duration: BezelMotion.of(context, BezelMotion.press),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
