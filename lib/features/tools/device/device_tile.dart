import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';

/// One device in the picker grid.
class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.label,
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String meta;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      label: label,
      selected: selected,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? BezelColors.accentSoft : const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(BezelRadius.control + 2),
          border: Border.all(color: selected ? BezelColors.accentLine : BezelColors.stroke),
        ),
        child: Row(children: [
          const Icon(Icons.phone_iphone_outlined, size: 22, color: BezelColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: BezelType.label, maxLines: 2),
                Text(meta, style: BezelType.caption),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
