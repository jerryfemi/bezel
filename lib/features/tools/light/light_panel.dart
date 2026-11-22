import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/slider_row.dart';
import '../../../core/widgets/toggle_row.dart';
import 'light_provider.dart';

class LightPanel extends ConsumerWidget {
  const LightPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(lightProvider);
    final notifier = ref.read(lightProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SliderRow(
        label: 'Direction', value: light.angle, min: 0, max: 360,
        format: (v) => '${v.round()}° ${_compass(v)}', onChanged: notifier.setAngle,
      ),
      SliderRow(
        label: 'Strength', value: light.intensity, min: 0, max: 1,
        format: (v) => '${(v * 100).round()}%', onChanged: notifier.setIntensity,
      ),
      ToggleRow(
        label: 'Reflections', value: light.reflections, onChanged: notifier.setReflections),
    ]);
  }

  /// Where the light comes from, in words.
  static String _compass(double deg) {
    const names = ['top', 'top-right', 'right', 'bottom-right', 'bottom', 'bottom-left', 'left', 'top-left'];
    return names[((deg % 360) / 45).round() % 8];
  }
}
