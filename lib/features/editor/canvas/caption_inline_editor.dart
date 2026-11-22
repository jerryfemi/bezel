import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../scene3d/scene_specs.dart';
import '../../tools/background/background_provider.dart';
import '../../tools/text/caption_font_style.dart';
import '../../tools/text/caption_provider.dart';
import 'caption_box.dart';

/// A text field laid over one caption part, in its own typeface and size.
/// The scene hides its copy of that part meanwhile. Click outside or press
/// Esc to finish.
class CaptionInlineEditor extends ConsumerStatefulWidget {
  const CaptionInlineEditor({super.key, required this.part, required this.frame});

  final CaptionPart part;
  final Size frame;

  @override
  ConsumerState<CaptionInlineEditor> createState() => _CaptionInlineEditorState();
}

class _CaptionInlineEditorState extends ConsumerState<CaptionInlineEditor> {
  bool get _isHead => widget.part == CaptionPart.headline;

  late final _text = TextEditingController(
      text: _isHead ? ref.read(captionProvider).headline : ref.read(captionProvider).subtitle);

  void _finish() => ref.read(captionProvider.notifier).setEditing(null);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(captionProvider);
    final notifier = ref.read(captionProvider.notifier);
    final light = _lightText(ref.watch(backgroundProvider).spec);
    final f = widget.frame;
    final style = _isHead
        ? CaptionFontStyle.headline(
            c.font,
            math.min(f.width, f.height) * CaptionFontStyle.headlineScale(c.font) * c.size,
            light ? const Color(0xFFF5F5F7) : const Color(0xFF111114))
        : CaptionFontStyle.subtitle(
            c.font,
            math.min(f.height * 0.034, f.width * 0.04) * c.subSize,
            light ? const Color(0xFFB4B8C2) : const Color(0xFF4A4A52));

    return TapRegion(
      onTapOutside: (_) => _finish(),
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _finish},
        child: Padding(
          padding: const EdgeInsets.all(CaptionBox.pad),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxHeight: double.infinity,
            child: TextField(
              controller: _text,
              autofocus: true,
              onChanged: _isHead ? notifier.setHeadline : notifier.setSubtitle,
              maxLines: null,
              textAlign: TextAlign.values.byName(c.align.name),
              style: style,
              cursorColor: BezelColors.accentLine,
              decoration: const InputDecoration.collapsed(hintText: null),
            ),
          ),
        ),
      ),
    );
  }

  /// Same rule as textColors() in web/scene/backdrop.js.
  static bool _lightText(BackgroundSpec bg) {
    if (bg.style == BackgroundStyle.image) return true;
    final n = int.parse(bg.colorHex.replaceFirst('#', ''), radix: 16);
    final r = ((n >> 16) & 255) / 255, g = ((n >> 8) & 255) / 255, b = (n & 255) / 255;
    return 0.2126 * r + 0.7152 * g + 0.0722 * b <= 0.5;
  }
}
