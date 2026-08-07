import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';

class LeftRailWidget extends ConsumerWidget {
  const LeftRailWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(activeEditorToolProvider);

    return Container(
      width: 72,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _RailIcon(
            icon: Icons.smartphone,
            tooltip: 'Device',
            isActive: activeTool == EditorTool.device,
            onTap: () => ref.read(activeEditorToolProvider.notifier).state = EditorTool.device,
          ),
          const SizedBox(height: 16),
          _RailIcon(
            icon: Icons.format_color_fill,
            tooltip: 'Background',
            isActive: activeTool == EditorTool.background,
            onTap: () => ref.read(activeEditorToolProvider.notifier).state = EditorTool.background,
          ),
          const Spacer(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _RailIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _RailIcon({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon),
        color: isActive ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
        onPressed: onTap,
        iconSize: 28,
      ),
    );
  }
}
