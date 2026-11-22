import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_type.dart';

/// Placeholder body for a tool that is planned but not built yet.
class ComingSoonPanel extends StatelessWidget {
  const ComingSoonPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message,
        style: BezelType.body.copyWith(color: BezelColors.textSecondary, height: 1.5));
  }
}
