import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_icons.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../home/open_project.dart';
import '../../projects/widgets/bezel_mark.dart';
import '../top_bar/project_title.dart';

/// Top-left in the editor: the logo, the project's name (click to rename),
/// and the way back to Home.
class ProjectPill extends ConsumerWidget {
  const ProjectPill({super.key});

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
          icon: BezelIcons.home,
          tooltip: 'All projects',
          size: 34,
          onTap: () => Navigate(ref).home(),
        ),
      ]),
    );
  }
}
