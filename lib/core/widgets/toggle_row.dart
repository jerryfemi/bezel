import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_type.dart';

/// A label with an on/off switch. The whole row is the tap target.
class ToggleRow extends StatelessWidget {
  const ToggleRow({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onChanged(!value),
        child: SizedBox(
          height: 40,
          child: Row(children: [
            Text(label, style: BezelType.body),
            const Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: BezelColors.accent,
              activeThumbColor: Colors.white,
            ),
          ]),
        ),
      ),
    );
  }
}
