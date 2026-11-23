import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_icons.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../projects/state/projects_provider.dart';
import '../../projects/widgets/bezel_mark.dart';
import '../top_bar/project_title.dart';

/// Top-left, while the sidebar is hidden: the logo, the project name, and the
/// button that brings the sidebar back.
class SidebarPill extends ConsumerWidget {
  const SidebarPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingSurface(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const BezelMark(),
        const SizedBox(width: 4),
        const ProjectTitle(),
        IconToolButton(
          icon: BezelIcons.sidebar,
          tooltip: 'Show sidebar',
          shortcut: 'Ctrl+\\',
          size: 34,
          onTap: () => ref.read(projectsMenuOpenProvider.notifier).state = true,
        ),
      ]),
    );
  }
}
