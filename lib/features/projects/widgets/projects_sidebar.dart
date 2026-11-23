import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../../core/widgets/pointer_shield.dart';
import '../../../core/widgets/pressable.dart';
import '../data/project_store.dart';
import '../state/projects_provider.dart';
import '../../editor/top_bar/project_title.dart';
import 'bezel_mark.dart';
import 'project_row.dart';

/// The left sidebar: a clear "New project" button and every saved project.
/// Docked beside the canvas (not floating over it); collapses to nothing.
class ProjectsSidebar extends ConsumerWidget {
  const ProjectsSidebar({super.key});

  static const width = 264.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final notifier = ref.read(projectsProvider.notifier);

    return PointerShield(
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          color: Color(0xFF131316),
          border: Border(right: BorderSide(color: BezelColors.stroke)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const SizedBox(width: 2),
            const BezelMark(),
            const SizedBox(width: 4),
            const Expanded(child: ProjectTitle()),
            IconToolButton(
              icon: BezelIcons.sidebar,
              tooltip: 'Hide sidebar',
              shortcut: 'Ctrl+\\',
              size: 32,
              onTap: () => ref.read(projectsMenuOpenProvider.notifier).state = false,
            ),
          ]),
          const SizedBox(height: 14),
          Container(height: 1, color: BezelColors.stroke),
          const SizedBox(height: 12),
          _NewProjectButton(onTap: notifier.newProject),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Text('Recent', style: BezelType.section),
          ),
          if (!ProjectStore.available)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text('This browser is blocking storage, so projects won\'t be kept.',
                  style: BezelType.caption.copyWith(color: BezelColors.danger)),
            ),
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: [
              for (final doc in projects.projects)
                ProjectRow(
                  doc: doc,
                  current: doc.id == projects.currentId,
                  onOpen: () {
                    if (doc.id != projects.currentId) notifier.open(doc.id);
                  },
                  onDuplicate: () => notifier.duplicate(doc.id),
                  onDelete: () => notifier.delete(doc.id),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 8),
            child: Text('Saved in this browser as you work.',
                style: BezelType.caption.copyWith(color: BezelColors.textTertiary)),
          ),
        ]),
      ),
    );
  }
}

class _NewProjectButton extends StatefulWidget {
  const _NewProjectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_NewProjectButton> createState() => _NewProjectButtonState();
}

class _NewProjectButtonState extends State<_NewProjectButton> {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _hover ? BezelColors.hover : null,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: BezelColors.accentSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(BezelIcons.add, size: 14, color: BezelColors.accentLine),
            ),
            const SizedBox(width: 10),
            Text('New project', style: BezelType.body.copyWith(fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}
