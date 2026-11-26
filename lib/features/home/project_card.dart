import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_colors.dart';
import '../../app/theme/bezel_type.dart';
import '../../core/widgets/pressable.dart';
import '../projects/model/project_doc.dart';
import '../projects/state/projects_provider.dart';
import '../scene3d/device_catalog.dart';
import 'card_menu.dart';
import 'card_thumb.dart';
import 'time_ago.dart';

/// One project on Home: its last frame, name, device and when it was edited.
/// Click opens it; the ⋯ menu renames, duplicates or deletes it.
class ProjectCard extends ConsumerStatefulWidget {
  const ProjectCard({super.key, required this.doc, required this.onOpen});

  final ProjectDoc doc;
  final VoidCallback onOpen;

  @override
  ConsumerState<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends ConsumerState<ProjectCard> {
  bool _hover = false;
  bool _renaming = false;
  bool _confirmDelete = false;
  late final _name = TextEditingController(text: widget.doc.title);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _finishRename() {
    setState(() => _renaming = false);
    ref.read(projectsProvider.notifier).rename(widget.doc.id, _name.text);
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final notifier = ref.read(projectsProvider.notifier);
    final device = deviceCatalog.where((e) => e.id == doc.deviceId).map((e) => e.label);
    final meta = '${device.isEmpty ? 'Device' : device.first} · ${timeAgo(doc.updatedAt)}';

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Pressable(
          onTap: _confirmDelete || _renaming ? null : widget.onOpen,
          label: 'Open ${doc.title}',
          pressedScale: 0.98,
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: CardThumb(
              dataUrl: doc.thumbnail,
              lifted: _hover,
              overlay: _confirmDelete
                  ? DeleteConfirm(
                      onDelete: () => notifier.delete(doc.id),
                      onKeep: () => setState(() => _confirmDelete = false),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _renaming
                  ? TextField(
                      controller: _name,
                      autofocus: true,
                      style: BezelType.body.copyWith(fontWeight: FontWeight.w600),
                      cursorColor: BezelColors.accentLine,
                      onSubmitted: (_) => _finishRename(),
                      onTapOutside: (_) => _finishRename(),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 2),
                        border: InputBorder.none,
                      ),
                    )
                  : Text(doc.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BezelType.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(meta, style: BezelType.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _hover ? 1 : 0,
            child: CardMenu(
              onRename: () => setState(() {
                _name.text = doc.title;
                _renaming = true;
              }),
              onDuplicate: () => notifier.duplicate(doc.id),
              onDelete: () => setState(() => _confirmDelete = true),
            ),
          ),
        ]),
      ]),
    );
  }
}
