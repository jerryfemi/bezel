import 'package:flutter/material.dart';

import '../../app/theme/bezel_metrics.dart';
import '../../app/theme/bezel_type.dart';

/// A titled group inside a tool panel.
class PanelSection extends StatelessWidget {
  const PanelSection({super.key, required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Text(title, style: BezelType.section),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: BezelSpace.s8),
        child,
      ],
    );
  }
}
