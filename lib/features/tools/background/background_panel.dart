import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../../core/widgets/swatch_button.dart';
import '../../scene3d/scene_specs.dart';
import 'background_image_row.dart';
import 'background_provider.dart';
import 'scene_backgrounds.dart';

class BackgroundPanel extends ConsumerWidget {
  const BackgroundPanel({super.key});

  static const _labels = {
    BackgroundStyle.solid: 'Solid',
    BackgroundStyle.spotlight: 'Spotlight',
    BackgroundStyle.image: 'Image',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bg = ref.watch(backgroundProvider);
    final notifier = ref.read(backgroundProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SegmentedControl<BackgroundStyle>(
        options: BackgroundStyle.values,
        selected: bg.style,
        labelOf: (s) => _labels[s]!,
        onChanged: notifier.setStyle,
      ),
      const SizedBox(height: 16),
      if (bg.style == BackgroundStyle.image) ...[
        BackgroundImageRow(name: bg.imageName, onPick: notifier.pickImage),
        const SizedBox(height: 16),
      ],
      PanelSection(
        title: bg.style == BackgroundStyle.image ? 'Colour behind the image' : 'Colour',
        trailing: Text(bg.swatch.name, style: BezelType.label),
        child: Wrap(children: [
          for (final swatch in sceneBackgrounds)
            SwatchButton(
              color: swatch.color,
              label: swatch.name,
              round: false,
              size: 34,
              selected: swatch == bg.swatch,
              onTap: () => notifier.setSwatch(swatch),
            ),
        ]),
      ),
    ]);
  }
}
