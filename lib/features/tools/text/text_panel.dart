import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/icon_segmented_control.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/slider_row.dart';
import '../../../core/widgets/toggle_row.dart';
import '../../scene3d/scene_specs.dart';
import 'caption_field.dart';
import 'caption_provider.dart';
import 'font_list.dart';

class TextPanel extends ConsumerWidget {
  const TextPanel({super.key});

  static const _sides = {
    CaptionSide.left: (Icons.align_horizontal_left, 'Text on the left'),
    CaptionSide.above: (Icons.align_vertical_top, 'Text on top'),
    CaptionSide.right: (Icons.align_horizontal_right, 'Text on the right'),
  };

  static const _aligns = {
    CaptionAlign.left: (Icons.format_align_left, 'Align left'),
    CaptionAlign.center: (Icons.format_align_center, 'Align center'),
    CaptionAlign.right: (Icons.format_align_right, 'Align right'),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caption = ref.watch(captionProvider);
    final notifier = ref.read(captionProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ToggleRow(label: 'Show caption', value: caption.enabled, onChanged: notifier.setEnabled),
      const SizedBox(height: 10),
      CaptionField(
          label: 'Headline', value: caption.headline, bold: true, onChanged: notifier.setHeadline),
      const SizedBox(height: 12),
      CaptionField(label: 'Subtitle', value: caption.subtitle, onChanged: notifier.setSubtitle),
      const SizedBox(height: 6),
      Text('Or double-click the text on the canvas to type there. Drag it to move it.',
          style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
      const SizedBox(height: 16),
      PanelSection(
        title: 'Typeface',
        child: FontList(selected: caption.font, onChanged: notifier.setFont),
      ),
      const SizedBox(height: 12),
      SliderRow(
        label: 'Size',
        value: caption.size,
        min: 0.5,
        max: 2.0,
        format: (v) => '${(v * 100).round()}%',
        onChanged: notifier.setSize,
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: PanelSection(
            title: 'Place',
            child: IconSegmentedControl<CaptionSide>(
                options: _sides, selected: caption.side, onChanged: notifier.setSide),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PanelSection(
            title: 'Align',
            child: IconSegmentedControl<CaptionAlign>(
                options: _aligns, selected: caption.align, onChanged: notifier.setAlign),
          ),
        ),
      ]),
      if (caption.moved) ...[
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: ChipButton(
              icon: Icons.restart_alt, label: 'Reset position', onTap: notifier.resetPosition),
        ),
      ],
    ]);
  }
}
