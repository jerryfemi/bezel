import 'package:flutter/material.dart';

import '../../../../app/theme/bezel_colors.dart';
import '../../../../app/theme/bezel_metrics.dart';
import '../../../../app/theme/bezel_type.dart';
import '../../../../core/widgets/floating_surface.dart';

/// The right panel's frame: a title, an optional line under it, optional
/// tabs, then the settings, which scroll.
class InspectorPanel extends StatelessWidget {
  const InspectorPanel({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.tabs,
  });

  final String title;
  final String? subtitle;
  final Widget? tabs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FloatingSurface(
      radius: BezelRadius.panel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: BezelType.title),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, style: BezelType.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),
        const SizedBox(height: 10),
        if (tabs != null) tabs!,
        Container(height: 1, color: BezelColors.stroke),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: child,
          ),
        ),
      ]),
    );
  }
}
