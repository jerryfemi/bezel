import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../core/widgets/pressable.dart';
import '../state/projects_provider.dart';

/// Shows or hides the projects sidebar (also Ctrl/Cmd + \\).
class ProjectsButton extends ConsumerWidget {
  const ProjectsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(projectsMenuOpenProvider);
    return Tooltip(
      message: open ? 'Hide projects' : 'Show projects',
      waitDuration: const Duration(milliseconds: 500),
      child: Pressable(
        onTap: () => ref.read(projectsMenuOpenProvider.notifier).state = !open,
        label: open ? 'Hide projects' : 'Show projects',
        selected: open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: open ? BezelColors.selected : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.view_sidebar_outlined, size: 16, color: BezelColors.textPrimary),
        ),
      ),
    );
  }
}
