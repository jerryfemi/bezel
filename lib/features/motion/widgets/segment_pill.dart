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
  const SegmentPillFace({super.key, required this.easing, required this.selected});

  final MotionEasing easing;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: BezelMotion.of(context, BezelMotion.press),
      margin: const EdgeInsets.symmetric(horizontal: 9),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0x525A8CFF) : BezelColors.accentSoft,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: selected ? BezelColors.accentLine : Colors.transparent),
      ),
      child: Text(
        easing.kind.name,
        style: BezelType.caption.copyWith(
          color: selected ? BezelColors.textPrimary : BezelColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
