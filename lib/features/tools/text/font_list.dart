import 'package:flutter/material.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../core/widgets/pressable.dart';
import '../../scene3d/scene_specs.dart';
import 'caption_font_style.dart';

/// Typeface picker. Collapsed, it shows only the chosen typeface; tapping it
/// opens the list, where each option is its name set in that typeface.
class FontList extends StatefulWidget {
  const FontList({super.key, required this.selected, required this.onChanged});

  final CaptionFont selected;
  final ValueChanged<CaptionFont> onChanged;

  @override
  State<FontList> createState() => _FontListState();
}

class _FontListState extends State<FontList> {
  bool _open = false;

  void _pick(CaptionFont font) {
    if (!_open) return setState(() => _open = true);
    setState(() => _open = false);
    if (font != widget.selected) widget.onChanged(font);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _open ? CaptionFont.values : [widget.selected];
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(children: [
        for (final font in shown)
          Padding(
            padding: EdgeInsets.only(bottom: _open ? 4 : 0),
            child: _FontRow(
              font: font,
              selected: font == widget.selected,
              open: _open,
              onTap: () => _pick(font),
            ),
          ),
      ]),
    );
  }
}

class _FontRow extends StatelessWidget {
  const _FontRow({required this.font, required this.selected, required this.open, required this.onTap});

  final CaptionFont font;
  final bool selected;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = selected && open;
    return Pressable(
      onTap: onTap,
      label: open ? font.label : 'Typeface: ${font.label}. Tap to change.',
      selected: selected,
      pressedScale: 0.98,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: highlight ? BezelColors.selected : const Color(0x0AFFFFFF),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: highlight ? BezelColors.accentLine : BezelColors.stroke),
        ),
        child: Row(children: [
          Expanded(
            child: Text(font.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CaptionFontStyle.headline(font, 16, BezelColors.textPrimary)
                    .copyWith(height: 1.1)),
          ),
          if (!open)
            const Icon(Icons.unfold_more, size: 16, color: BezelColors.textSecondary)
          else if (selected)
            const Icon(Icons.check, size: 15, color: BezelColors.accentLine),
        ]),
      ),
    );
  }
}
