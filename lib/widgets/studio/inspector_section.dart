import 'package:flutter/material.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

class PanelSectionHeader extends StatelessWidget {
  final String title;

  const PanelSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.panelHeader,
      ),
    );
  }
}

class InspectorSection extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showDivider;

  const InspectorSection({
    super.key,
    required this.title,
    required this.child,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PanelSectionHeader(title: title),
        child,
        if (showDivider) ...[
          const SizedBox(height: AppSpacing.s24),
          const Divider(),
          const SizedBox(height: AppSpacing.s24),
        ],
      ],
    );
  }
}
