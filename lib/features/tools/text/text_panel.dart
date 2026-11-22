import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../../core/widgets/toggle_row.dart';
import '../../scene3d/scene_specs.dart';
import 'caption_field.dart';
import 'caption_provider.dart';

class TextPanel extends ConsumerWidget {
  const TextPanel({super.key});

  static const _sides = {
    CaptionSide.left: 'Left',
    CaptionSide.above: 'Above',
    CaptionSide.right: 'Right',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caption = ref.watch(captionProvider);
    final notifier = ref.read(captionProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ToggleRow(label: 'Show caption', value: caption.enabled, onChanged: notifier.setEnabled),
      const SizedBox(height: 10),
      CaptionField(
        label: 'Headline', initial: caption.headline, bold: true, onChanged: notifier.setHeadline),
      const SizedBox(height: 12),
      CaptionField(label: 'Subtitle', initial: caption.subtitle, onChanged: notifier.setSubtitle),
      const SizedBox(height: 16),
      PanelSection(
        title: 'Position',
        child: SegmentedControl<CaptionSide>(
          options: CaptionSide.values,
          selected: caption.side,
          labelOf: (s) => _sides[s]!,
          onChanged: notifier.setSide,
        ),
      ),
      const SizedBox(height: 8),
      Text('Tall frames (4:5, 9:16) always place the caption above.',
          style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
    ]);
  }
}
