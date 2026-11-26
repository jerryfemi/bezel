import 'package:flutter/material.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_icons.dart';
import '../../app/theme/bezel_type.dart';
import '../../core/widgets/pressable.dart';

/// The first tile on Home: starts a blank project and opens it.
class NewProjectTile extends StatefulWidget {
  const NewProjectTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<NewProjectTile> createState() => _NewProjectTileState();
}

class _NewProjectTileState extends State<NewProjectTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Pressable(
        onTap: widget.onTap,
        label: 'New project',
        pressedScale: 0.98,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: _hover ? const Color(0x382F62E0) : const Color(0x1F2F62E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _hover ? BezelColors.accentLine : const Color(0x4D8FB0FF)),
              ),
              child: const Center(
                child: Icon(BezelIcons.add, size: 28, color: BezelColors.accentLine),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('New project', style: BezelType.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text('Start from a blank phone', style: BezelType.caption),
        ]),
      ),
    );
  }
}
