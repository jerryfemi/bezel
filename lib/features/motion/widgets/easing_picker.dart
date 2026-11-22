import 'package:flutter/material.dart';

import '../../../core/widgets/segmented_control.dart';
import '../../../core/widgets/slider_row.dart';
import '../model/motion_easing.dart';

/// Spring / Ease / Linear, plus bounce for springs.
class EasingPicker extends StatelessWidget {
  const EasingPicker({super.key, required this.easing, required this.onChanged});

  final MotionEasing easing;
  final ValueChanged<MotionEasing> onChanged;

  static const _labels = {
    EasingKind.spring: 'Spring',
    EasingKind.ease: 'Ease',
    EasingKind.linear: 'Linear',
  };

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SegmentedControl<EasingKind>(
        options: EasingKind.values,
        selected: easing.kind,
        labelOf: (k) => _labels[k]!,
        onChanged: (k) => onChanged(MotionEasing(k, bounce: easing.bounce)),
      ),
      if (easing.kind == EasingKind.spring) ...[
        const SizedBox(height: 10),
        SliderRow(
          label: 'Bounce', value: easing.bounce, min: 0, max: 0.5,
          format: (v) => v.toStringAsFixed(2),
          onChanged: (v) => onChanged(MotionEasing(EasingKind.spring, bounce: v)),
        ),
      ],
    ]);
  }
}
