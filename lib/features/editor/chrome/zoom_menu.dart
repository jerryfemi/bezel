import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../scene3d/scene_pose.dart';
import '../state/scene_provider.dart';

/// The device zoom as "100% ⌄"; the menu zooms in, out, or back to 100%.
class ZoomMenu extends ConsumerWidget {
  const ZoomMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(sceneControllerProvider);
    if (scene == null) return const SizedBox.shrink();

    return ValueListenableBuilder<ScenePose>(
      valueListenable: scene.pose,
      builder: (context, pose, _) {
        void zoomTo(double z) => scene.setPose(pose.copyWith(zoom: z.clamp(0.5, 2.5)));
        return PopupMenuButton<VoidCallback>(
          tooltip: 'Zoom',
          position: PopupMenuPosition.under,
          onSelected: (action) => action(),
          itemBuilder: (_) => [
            _item('Zoom in', () => zoomTo(pose.zoom + 0.1)),
            _item('Zoom out', () => zoomTo(pose.zoom - 0.1)),
            const PopupMenuDivider(),
            _item('Zoom to 100%', () => zoomTo(1)),
          ],
          child: SizedBox(
            height: 34,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(width: 8),
              Text('${(pose.zoom * 100).round()}%', style: BezelType.body.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(width: 2),
              const Icon(BezelIcons.chevronDown, size: 14, color: BezelColors.textSecondary),
              const SizedBox(width: 6),
            ]),
          ),
        );
      },
    );
  }

  PopupMenuItem<VoidCallback> _item(String label, VoidCallback action) =>
      PopupMenuItem(value: action, height: 36, child: Text(label, style: BezelType.body));
}
