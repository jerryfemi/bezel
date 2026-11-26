import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_type.dart';
import '../projects/data/project_store.dart';
import '../projects/state/projects_provider.dart';
import '../projects/widgets/bezel_mark.dart';
import 'new_project_tile.dart';
import 'open_project.dart';
import 'project_card.dart';

/// Home: every saved project as a card, newest first, with "New project"
/// as the first tile.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _cardWidth = 260.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).projects;
    final go = Navigate(ref);
    return Material(
      color: BezelColors.canvas,
      child: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
            child: Row(children: [
              const BezelMark(size: 30),
              const SizedBox(width: 10),
              Text('Bezel', style: BezelType.brand),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 44, 40, 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Projects',
                  style: BezelType.title.copyWith(fontSize: 28, letterSpacing: -0.6)),
              const SizedBox(height: 6),
              Text(
                ProjectStore.available
                    ? 'Saved in this browser as you work.'
                    : 'This browser is blocking storage, so projects won\'t be kept.',
                style: BezelType.label.copyWith(color: BezelColors.textSecondary),
              ),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _cardWidth,
              mainAxisSpacing: 24,
              crossAxisSpacing: 20,
              childAspectRatio: 0.92,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => i == 0
                  ? NewProjectTile(onTap: go.newProject)
                  : ProjectCard(
                      key: ValueKey(projects[i - 1].id),
                      doc: projects[i - 1],
                      onOpen: () => go.open(projects[i - 1].id),
                    ),
              childCount: projects.length + 1,
            ),
          ),
        ),
      ]),
    );
  }
}
