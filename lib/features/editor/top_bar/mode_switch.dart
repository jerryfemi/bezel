import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';

/// Design / Motion switch. Motion mode arrives in phase 5.
class ModeSwitch extends StatelessWidget {
  const ModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingSurface(
      radius: BezelRadius.control + 2,
      padding: const EdgeInsets.all(3),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _mode('Design', selected: true),
        Tooltip(message: 'Motion editing is coming next', child: _mode('Motion', selected: false)),
      ]),
    );
  }

  Widget _mode(String label, {required bool selected}) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? BezelColors.selected : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(label, style: BezelType.body.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? BezelColors.textPrimary : BezelColors.textTertiary,
      )),
    );
  }
}
