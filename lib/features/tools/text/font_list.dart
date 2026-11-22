import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../core/widgets/pressable.dart';
import '../../scene3d/scene_specs.dart';
import 'caption_font_style.dart';

/// Typeface picker: each option is its name, set in that typeface.
class FontList extends StatelessWidget {
  const FontList({super.key, required this.selected, required this.onChanged});

  final CaptionFont selected;
  final ValueChanged<CaptionFont> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      for (final font in CaptionFont.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Pressable(
            onTap: () => onChanged(font),
            label: font.label,
            selected: font == selected,
            pressedScale: 0.98,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: font == selected ? BezelColors.selected : const Color(0x0AFFFFFF),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                    color: font == selected ? BezelColors.accentLine : BezelColors.stroke),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(font.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CaptionFontStyle.headline(font, 16, BezelColors.textPrimary)
                          .copyWith(height: 1.1)),
                ),
                if (font == selected)
                  const Icon(Icons.check, size: 15, color: BezelColors.accentLine),
              ]),
            ),
          ),
        ),
    ]);
  }
}
