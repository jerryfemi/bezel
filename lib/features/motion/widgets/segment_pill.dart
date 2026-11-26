import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_motion.dart';
import '../../../app/theme/bezel_type.dart';
import '../model/motion_easing.dart';

/// One move between two keyframes. Tap to select it (and loop it);
/// drag sideways to carry it to another place in the clip.
class SegmentPill extends StatelessWidget {
  const SegmentPill({
    super.key,
    required this.easing,
    required this.selected,
    required this.ghost,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final MotionEasing easing;
  final bool selected;

  /// True while this pill is being dragged (its old slot fades).
  final bool ghost;
  final VoidCallback onTap;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: (_) => onDragEnd(),
        onHorizontalDragCancel: onDragEnd,
        child: AnimatedOpacity(
          duration: BezelMotion.of(context, BezelMotion.press),
          opacity: ghost ? 0.3 : 1,
          child: SegmentPillFace(easing: easing, selected: selected),
        ),
      ),
    );
  }
}

/// The pill's look, shared with the copy that follows the pointer while dragging.
class SegmentPillFace extends StatelessWidget {
  const SegmentPillFace({super.key, required this.easing, required this.selected, this.label});

  final MotionEasing easing;
  final bool selected;

  /// Shown instead of the easing's name.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: BezelMotion.of(context, BezelMotion.press),
      // A block like the other tracks' clips; a hairline gap marks each keyframe.
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A55),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: selected ? const Color(0xFF8FB0FF) : const Color(0x738FB0FF),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Text(
        label ?? easing.kind.name,
        style: BezelType.caption.copyWith(
          color: selected ? BezelColors.textPrimary : const Color(0xFFDCE6FF),
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
