import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/swatch_button.dart';
import 'background_provider.dart';
import 'scene_backgrounds.dart';

class BackgroundPanel extends ConsumerWidget {
  const BackgroundPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(backgroundProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PanelSection(
        title: 'Colour',
        trailing: Text(current.name, style: BezelType.label),
        child: Wrap(children: [
          for (final bg in sceneBackgrounds)
            SwatchButton(
              color: bg.color,
              label: bg.name,
              round: false,
              size: 34,
              selected: bg == current,
              onTap: () => ref.read(backgroundProvider.notifier).select(bg),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      Text('Gradients, spotlight and image backgrounds come next.',
          style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
    ]);
  }
}
