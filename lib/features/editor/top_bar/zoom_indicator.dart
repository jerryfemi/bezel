import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../scene3d/scene_pose.dart';
import '../state/scene_provider.dart';

/// The device's zoom (scroll or pinch on the phone) with a Reset to 100%.
class ZoomIndicator extends ConsumerWidget {
  const ZoomIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(sceneControllerProvider);
    if (scene == null) return const SizedBox.shrink();
    return ValueListenableBuilder<ScenePose>(
      valueListenable: scene.pose,
      builder: (_, pose, __) {
        final atDefault = (pose.zoom - 1).abs() < 0.005;
        return FloatingSurface(
          radius: BezelRadius.control + 2,
          padding: const EdgeInsets.only(left: 14, right: 4),
          child: SizedBox(
            height: 44,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.zoom_in, size: 16, color: BezelColors.textSecondary),
              const SizedBox(width: 6),
              SizedBox(
                width: 44,
                child: Text('${(pose.zoom * 100).round()}%', style: BezelType.mono),
              ),
              TextButton(
                onPressed: atDefault ? null : () => scene.setPose(pose.copyWith(zoom: 1)),
                style: TextButton.styleFrom(foregroundColor: BezelColors.accentLine),
                child: const Text('Reset'),
              ),
            ]),
          ),
        );
      },
    );
  }
}
