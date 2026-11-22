import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';
import 'device_preview.dart';

/// One device in the picker: a preview on a soft stage, then its name.
class DeviceTile extends StatelessWidget {
  const DeviceTile({
    super.key,
    required this.label,
    required this.meta,
    required this.bodyColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String meta;
  final Color bodyColor;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      label: label,
      selected: selected,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? BezelColors.accentSoft : const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(BezelRadius.control + 4),
          border: Border.all(color: selected ? BezelColors.accentLine : BezelColors.stroke),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BezelRadius.control),
              gradient: const RadialGradient(
                center: Alignment(0, -0.3),
                radius: 0.9,
                colors: [Color(0xFF2B3447), Color(0xFF161A22)],
              ),
            ),
            child: DevicePreview(bodyColor: bodyColor),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: BezelType.label.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(meta, style: BezelType.caption),
            ]),
          ),
        ]),
      ),
    );
  }
}
