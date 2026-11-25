import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../projects/state/projects_provider.dart';
import '../../projects/widgets/projects_sidebar.dart';
import '../state/editor_layout.dart';

/// The projects sidebar, docked left of the canvas. Drag its right edge to
/// resize it; it slides shut to nothing when hidden.
class SidebarDock extends ConsumerStatefulWidget {
  const SidebarDock({super.key});

  @override
  ConsumerState<SidebarDock> createState() => _SidebarDockState();
}

class _SidebarDockState extends ConsumerState<SidebarDock> {
  bool _dragging = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final open = ref.watch(projectsMenuOpenProvider);
    final width = ref.watch(sidebarWidthProvider);
    return AnimatedContainer(
      // Follows the pointer exactly while resizing; animates open and shut.
      duration: _dragging ? Duration.zero : const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: open ? width : 0,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerRight,
          minWidth: width,
          maxWidth: width,
          child: Stack(children: [
            const Positioned.fill(child: ProjectsSidebar()),
            Positioned(top: 0, bottom: 0, right: 0, width: 8, child: _handle()),
          ]),
        ),
      ),
    );
  }

  Widget _handle() {
    final active = _dragging || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _dragging = true),
        onHorizontalDragUpdate: (d) {
          final next = (ref.read(sidebarWidthProvider) + d.delta.dx)
              .clamp(EditorLayout.sidebarMin, EditorLayout.sidebarMax);
          ref.read(sidebarWidthProvider.notifier).state = next.toDouble();
        },
        onHorizontalDragEnd: (_) => setState(() => _dragging = false),
        onDoubleTap: () {
          HapticFeedback.selectionClick();
          ref.read(sidebarWidthProvider.notifier).state = ProjectsSidebar.width;
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 2,
            color: active ? BezelColors.accentLine : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
