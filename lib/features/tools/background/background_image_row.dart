import 'package:flutter/material.dart';

import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';

/// The chosen background image, with a button to choose another.
class BackgroundImageRow extends StatelessWidget {
  const BackgroundImageRow({super.key, required this.name, required this.onPick});

  final String? name;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(BezelRadius.control + 2),
      ),
      child: Row(children: [
        Expanded(
          child: Text(name ?? 'No image yet',
              style: BezelType.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        TextButton(onPressed: onPick, child: Text(name == null ? 'Choose' : 'Replace')),
      ]),
    );
  }
}
