import 'package:flutter/material.dart';

import '../../app/theme/bezel_type.dart';

/// Label and live value above a slider. Updates continuously while dragging.
class SliderRow extends StatelessWidget {
  const SliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(label, style: BezelType.label),
            const Spacer(),
            Text(format(value), style: BezelType.mono),
          ],
        ),
        SizedBox(
          height: 28,
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            label: label,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
