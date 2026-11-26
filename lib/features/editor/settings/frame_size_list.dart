import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';
import '../state/frame_shape.dart';

/// The four video shapes, each with a small outline of its proportions and
/// where it's used.
class FrameSizeList extends ConsumerWidget {
  const FrameSizeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(frameShapeProvider);
    return Column(children: [
      for (final shape in FrameShape.values)
        Pressable(
          onTap: () => ref.read(frameShapeProvider.notifier).state = shape,
          label: shape.label,
          selected: shape == current,
          pressedScale: 0.98,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: shape == current ? BezelColors.selected : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              SizedBox(width: 24, height: 20, child: Center(child: _ShapeOutline(shape: shape))),
              const SizedBox(width: 10),
              SizedBox(width: 36, child: Text(shape.label, style: BezelType.mono)),
              Expanded(
                child: Text(shape.usedFor,
                    style: BezelType.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        ),
    ]);
  }
}

class _ShapeOutline extends StatelessWidget {
  const _ShapeOutline({required this.shape});

  final FrameShape shape;

  @override
  Widget build(BuildContext context) {
    const box = 18.0;
    final w = shape.aspect >= 1 ? box : box * shape.aspect;
    final h = shape.aspect >= 1 ? box / shape.aspect : box;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        border: Border.all(color: BezelColors.textSecondary, width: 1.4),
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
