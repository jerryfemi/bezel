import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/slider_row.dart';
import '../../editor/state/scene_provider.dart';
import '../../scene3d/scene_position.dart';
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
                  onTap: () => scene.setPose(preset.pose.copyWith(zoom: pose.zoom)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ChipButton(
              icon: BezelIcons.center,
              label: 'Center device',
              onTap: () => scene.setPosition(const ScenePosition()),
            ),
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
          SliderRow(
            label: 'Zoom', value: pose.zoom, min: 0.5, max: 2.5,
            format: (v) => '${(v * 100).round()}%',
            onChanged: (v) => scene.setPose(pose.copyWith(zoom: v)),
          ),
          const SizedBox(height: 6),
          Text(
            'Drag the phone to turn it. Shift+drag (or the Move button in the left bar) places it in the frame. Scroll or pinch to zoom.',
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
