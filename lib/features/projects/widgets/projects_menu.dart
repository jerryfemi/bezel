import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/floating_surface.dart';
import '../data/project_store.dart';
import '../state/projects_provider.dart';
import 'project_row.dart';

/// The list of saved projects, dropped down from the top bar.
class ProjectsMenu extends ConsumerWidget {
  const ProjectsMenu({super.key});

  static const width = 340.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final notifier = ref.read(projectsProvider.notifier);
    void close() => ref.read(projectsMenuOpenProvider.notifier).state = false;

    return FloatingSurface(
      elevated: true,
      radius: 14,
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: width,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 0, 8),
            child: Row(children: [
              Text('Projects', style: BezelType.title),
              const Spacer(),
              ChipButton(
                icon: Icons.add,
                label: 'New',
                onTap: () {
                  close();
                  notifier.newProject();
                },
              ),
            ]),
          ),
          if (!ProjectStore.available)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('This browser is not letting Bezel save. Projects will not be kept.',
                  style: BezelType.label.copyWith(color: BezelColors.danger)),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 440),
            child: ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: [
              for (final doc in projects.projects)
                ProjectRow(
                  doc: doc,
                  current: doc.id == projects.currentId,
                  onOpen: () {
                    close();
                    if (doc.id != projects.currentId) notifier.open(doc.id);
                  },
                  onDuplicate: () {
                    close();
                    notifier.duplicate(doc.id);
                  },
                  onDelete: () => notifier.delete(doc.id),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}
