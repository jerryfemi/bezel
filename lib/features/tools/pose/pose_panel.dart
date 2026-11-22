import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/slider_row.dart';
import '../../editor/state/scene_provider.dart';
import '../../scene3d/scene_pose.dart';
import 'pose_presets.dart';
import 'pose_tile.dart';

class PosePanel extends ConsumerWidget {
  const PosePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(sceneControllerProvider);
    if (scene == null) return Text('Loading the device…', style: BezelType.body);

    return ValueListenableBuilder<ScenePose>(
      valueListenable: scene.pose,
      builder: (context, pose, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // Fixed tile height: thumbnail 70 + gap 6 + label + padding 12.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 112,
            ),
            children: [
              for (final preset in posePresets)
                PoseTile(
                  preset: preset,
                  selected: _near(pose, preset.pose),
                  onTap: () => scene.setPose(preset.pose),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SliderRow(
            label: 'Turn', value: pose.turn, min: -180, max: 180,
            format: _deg, onChanged: (v) => scene.setPose(pose.copyWith(turn: v)),
          ),
          SliderRow(
            label: 'Tilt', value: pose.tilt, min: -30, max: 60,
            format: _deg, onChanged: (v) => scene.setPose(pose.copyWith(tilt: v)),
          ),
          const SizedBox(height: 6),
          Text(
            'Or drag the phone itself. It turns all the way round; past 70° it '
            'resists a little so the back only shows when you mean it.',
            style: BezelType.label.copyWith(color: BezelColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  static String _deg(double v) => '${v.round()}°';

  static bool _near(ScenePose a, ScenePose b) =>
      (a.turn - b.turn).abs() < 1 && (a.tilt - b.tilt).abs() < 1;
}
