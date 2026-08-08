import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../studio/studio_icon_button.dart';

class LeftRailWidget extends ConsumerWidget {
  const LeftRailWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTool = ref.watch(activeEditorToolProvider);

    return Container(
      width: 72,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
      child: Column(
        children: [
          StudioIconButton(
            icon: Icons.smartphone,
            tooltip: 'Device',
            isActive: activeTool == EditorTool.device,
            onPressed: () => ref.read(activeEditorToolProvider.notifier).state = EditorTool.device,
          ),
          const SizedBox(height: AppSpacing.s12),
          StudioIconButton(
            icon: Icons.format_color_fill,
            tooltip: 'Background',
            isActive: activeTool == EditorTool.background,
            onPressed: () => ref.read(activeEditorToolProvider.notifier).state = EditorTool.background,
          ),
          const SizedBox(height: AppSpacing.s12),
          StudioIconButton(
            icon: Icons.crop,
            tooltip: 'Crop Media',
            isActive: activeTool == EditorTool.crop,
            onPressed: () => ref.read(activeEditorToolProvider.notifier).state = EditorTool.crop,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
