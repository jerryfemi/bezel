import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../scene3d/scene_specs.dart';
import '../../tools/background/background_provider.dart';
import '../../tools/text/caption_font_style.dart';
import '../../tools/text/caption_provider.dart';

/// Headline and subtitle fields laid over the canvas, in the caption's own
/// typeface and size. The scene hides its copy of the text meanwhile.
/// Click outside or press Esc to finish.
class CaptionInlineEditor extends ConsumerStatefulWidget {
  const CaptionInlineEditor({super.key, required this.frame});

  final Size frame;

  @override
  ConsumerState<CaptionInlineEditor> createState() => _CaptionInlineEditorState();
}

class _CaptionInlineEditorState extends ConsumerState<CaptionInlineEditor> {
  late final _caption = ref.read(captionProvider);
  late final _head = TextEditingController(text: _caption.headline);
  late final _sub = TextEditingController(text: _caption.subtitle);

  void _finish() => ref.read(captionProvider.notifier).setEditing(false);

  @override
  void dispose() {
    _head.dispose();
    _sub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(captionProvider);
    final light = _lightText(ref.watch(backgroundProvider).spec);
    final short = math.min(widget.frame.width, widget.frame.height);
    final headSize = short * CaptionFontStyle.headlineScale(c.font) * c.size;
    final subSize = math.min(widget.frame.height * 0.034, widget.frame.width * 0.04) * c.size;
    final align = TextAlign.values.byName(c.align.name);
    final notifier = ref.read(captionProvider.notifier);

    return TapRegion(
      onTapOutside: (_) => _finish(),
      child: CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): _finish},
        child: Padding(
          padding: const EdgeInsets.all(10), // matches the box's inflate
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(_head, CaptionFontStyle.headline(c.font, headSize,
                light ? const Color(0xFFF5F5F7) : const Color(0xFF111114)), align,
                notifier.setHeadline, autofocus: true),
            SizedBox(height: headSize * 0.45),
            _field(_sub, CaptionFontStyle.subtitle(c.font, subSize,
                light ? const Color(0xFFB4B8C2) : const Color(0xFF4A4A52)), align,
                notifier.setSubtitle),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, TextStyle style, TextAlign align,
      ValueChanged<String> onChanged, {bool autofocus = false}) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onChanged: onChanged,
      maxLines: null,
      textAlign: align,
      style: style,
      cursorColor: BezelColors.accentLine,
      decoration: const InputDecoration.collapsed(hintText: null),
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
