import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/icon_segmented_control.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/slider_row.dart';
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

    if (!caption.enabled) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('No caption at the playhead.',
            style: BezelType.body.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Add one here. Each caption is a block on the timeline, so you can show '
            'a different line every few seconds.',
            style: BezelType.label.copyWith(color: BezelColors.textSecondary, height: 1.45)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ChipButton(icon: Icons.add, label: 'Add caption', onTap: () => notifier.setEnabled(true)),
        ),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      CaptionField(
          label: 'Headline', value: caption.headline, bold: true, onChanged: notifier.setHeadline),
      const SizedBox(height: 12),
      CaptionField(label: 'Subtitle', value: caption.subtitle, onChanged: notifier.setSubtitle),
      const SizedBox(height: 6),
      Text('Or double-click either line on the canvas to type there. Drag the headline to move both; drag the subtitle to move it on its own.',
          style: BezelType.label.copyWith(color: BezelColors.textSecondary)),
      const SizedBox(height: 16),
      PanelSection(
        title: 'Typeface',
        child: FontList(selected: caption.font, onChanged: notifier.setFont),
      ),
      const SizedBox(height: 12),
      for (final (part, label, value) in [
        (CaptionPart.headline, 'Headline size', caption.size),
        (CaptionPart.subtitle, 'Subtitle size', caption.subSize),
      ])
        SliderRow(
          label: label,
          value: value,
          min: 0.5,
          max: 2.5,
          format: (v) => '${(v * 100).round()}%',
          onChanged: (v) => notifier.setSize(part, v),
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
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => notifier.setEnabled(false),
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Delete this caption'),
          style: TextButton.styleFrom(foregroundColor: BezelColors.danger),
        ),
      ),
    ]);
  }
}
