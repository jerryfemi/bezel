import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/slider_row.dart';
import '../../editor/state/scene_provider.dart';
import '../model/keyframe.dart';
import 'easing_picker.dart';

/// The editable values of one keyframe.
class KeyframeFields extends ConsumerWidget {
  const KeyframeFields({
    super.key,
    required this.keyframe,
    required this.maxTime,
    required this.onChanged,
  });

  final Keyframe keyframe;
  final double maxTime;
  final ValueChanged<Keyframe> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final k = keyframe;
    final pose = k.pose;
    String deg(double v) => '${v.round()}°';

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SliderRow(label: 'Time', value: k.time, min: 0, max: maxTime,
          format: (v) => '${v.toStringAsFixed(2)}s', onChanged: (v) => onChanged(k.copyWith(time: v))),
      SliderRow(label: 'Turn', value: pose.turn, min: -360, max: 360, format: deg,
          onChanged: (v) => onChanged(k.copyWith(pose: pose.copyWith(turn: v)))),
      SliderRow(label: 'Tilt', value: pose.tilt, min: -30, max: 60, format: deg,
          onChanged: (v) => onChanged(k.copyWith(pose: pose.copyWith(tilt: v)))),
      SliderRow(label: 'Zoom', value: pose.zoom, min: 0.5, max: 2.5,
          format: (v) => '${(v * 100).round()}%',
          onChanged: (v) => onChanged(k.copyWith(pose: pose.copyWith(zoom: v)))),
      Align(
        alignment: Alignment.centerLeft,
        child: ChipButton(
          icon: Icons.photo_camera_outlined,
          label: 'Use current pose',
          onTap: () {
            final live = ref.read(sceneControllerProvider)?.pose.value;
            if (live != null) onChanged(k.copyWith(pose: live));
          },
        ),
      ),
      const SizedBox(height: 16),
      PanelSection(
        title: 'Easing into this keyframe',
        child: EasingPicker(easing: k.easing, onChanged: (e) => onChanged(k.copyWith(easing: e))),
      ),
    ]);
  }
}
