import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/icon_tool_button.dart';
import '../../../core/widgets/pressable.dart';
import '../../export/state/export_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../timeline/model/tracks.dart';
import '../../timeline/state/tracks_provider.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_mode_provider.dart';
import '../state/scene_provider.dart';
import 'zoom_menu.dart';

/// Top-right: Design/Motion, zoom, play, and Export, the way design tools
/// keep "view and ship" controls together in one corner.
class CornerBar extends ConsumerWidget {
  const CornerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(editorModeProvider);
    final scene = ref.watch(sceneControllerProvider);
    // Anything to play: motion, or clips on the timeline.
    final hasMotion =
        clipLength(ref.watch(tracksProvider), ref.watch(timelineProvider).duration) > 0;
    final exportOpen = ref.watch(exportSheetOpenProvider);

    void setMode(EditorMode m) {
      ref.read(activeToolProvider.notifier).close();
      // Move mode's toggle lives in the Design dock; never carry it into
      // Motion, where dragging must turn the phone to set keyframes.
      ref.read(sceneInteractionModeProvider.notifier).state =
          SceneInteractionMode.rotate;
      scene?.setMoveMode(false);
      ref.read(editorModeProvider.notifier).state = m;
    }

    return FloatingSurface(
      radius: 14,
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeTab(
            'Design',
            mode == EditorMode.design,
            () => setMode(EditorMode.design),
          ),
          _ModeTab(
            'Timeline',
            mode == EditorMode.motion,
            () => setMode(EditorMode.motion),
          ),
          _gap(),
          const ZoomMenu(),
          if (scene != null)
            ValueListenableBuilder(
              valueListenable: scene.playing,
              builder: (_, playing, _) => IconToolButton(
                icon: playing ? BezelIcons.pause : BezelIcons.play,
                tooltip: hasMotion
                    ? (playing ? 'Pause' : 'Play')
                    : 'Add motion or clips to play',
                onTap: hasMotion ? (playing ? scene.pause : scene.play) : null,
              ),
            ),
          const SizedBox(width: 4),
          Pressable(
            onTap: () {
              ref.read(activeToolProvider.notifier).close();
              ref.read(exportSheetOpenProvider.notifier).state = !exportOpen;
            },
            label: 'Export',
            selected: exportOpen,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: BezelColors.accent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  const Icon(BezelIcons.export, size: 15, color: Colors.white),
                  const SizedBox(width: 7),
                  Text(
                    'Export',
                    style: BezelType.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap() => Container(
    width: 1,
    height: 20,
    color: BezelColors.stroke,
    margin: const EdgeInsets.symmetric(horizontal: 6),
  );
}

class _ModeTab extends StatelessWidget {
  const _ModeTab(this.label, this.selected, this.onTap);

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      label: label,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? BezelColors.selected : null,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: BezelType.body.copyWith(
            fontWeight: FontWeight.w600,
            color: selected
                ? BezelColors.textPrimary
                : BezelColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
