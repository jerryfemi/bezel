import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_type.dart';

enum _Action { rename, duplicate, delete }

/// The ⋯ menu on a project card.
class CardMenu extends StatelessWidget {
  const CardMenu({
    super.key,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    PopupMenuItem<_Action> item(_Action a, IconData icon, String label) => PopupMenuItem(
          value: a,
          height: 36,
          child: Row(children: [
            Icon(icon, size: 16, color: BezelColors.textSecondary),
            const SizedBox(width: 10),
            Text(label, style: BezelType.label),
          ]),
        );
    return PopupMenuButton<_Action>(
      tooltip: 'More',
      padding: EdgeInsets.zero,
      iconSize: 18,
      icon: const Icon(Icons.more_horiz, color: BezelColors.textSecondary),
      color: BezelColors.surfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: BezelColors.stroke),
      ),
      onSelected: (a) => switch (a) {
        _Action.rename => onRename(),
        _Action.duplicate => onDuplicate(),
        _Action.delete => onDelete(),
      },
      itemBuilder: (_) => [
        item(_Action.rename, Icons.edit_outlined, 'Rename'),
        item(_Action.duplicate, Icons.copy_outlined, 'Duplicate'),
        item(_Action.delete, Icons.delete_outline, 'Delete'),
      ],
    );
  }
}
