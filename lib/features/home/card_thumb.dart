import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_type.dart';
import '../../core/widgets/chip_button.dart';

/// A project's last frame, rounded, lifting a little on hover. [overlay]
/// covers it (the delete question).
class CardThumb extends StatelessWidget {
  const CardThumb({super.key, required this.dataUrl, required this.lifted, this.overlay});

  final String? dataUrl;
  final bool lifted;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    final bytes = dataUrl == null ? null : Uri.tryParse(dataUrl!)?.data?.contentAsBytes();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, lifted ? -3 : 0, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF18181C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lifted ? BezelColors.strokeStrong : BezelColors.stroke),
        boxShadow: [
          BoxShadow(
            color: Color(lifted ? 0x66000000 : 0x33000000),
            blurRadius: lifted ? 28 : 12,
            offset: Offset(0, lifted ? 12 : 4),
          ),
        ],
      ),
      child: Stack(fit: StackFit.expand, children: [
        bytes == null
            ? const Icon(Icons.smartphone_outlined, size: 28, color: BezelColors.textTertiary)
            : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
        ?overlay,
      ]),
    );
  }
}

/// Asks once more before a project is deleted.
class DeleteConfirm extends StatelessWidget {
  const DeleteConfirm({super.key, required this.onDelete, required this.onKeep});

  final VoidCallback onDelete;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xE60E0E11),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Delete this project?', style: BezelType.label.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Its files go too. This can\'t be undone.', style: BezelType.caption),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ChipButton(icon: Icons.delete_outline, label: 'Delete', onTap: onDelete),
          const SizedBox(width: 8),
          ChipButton(icon: Icons.close, label: 'Keep', onTap: onKeep),
        ]),
      ]),
    );
  }
}
