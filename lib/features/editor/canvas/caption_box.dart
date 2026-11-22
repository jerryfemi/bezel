import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../tools/text/caption_provider.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';
import 'caption_inline_editor.dart';

/// The caption's outline on the canvas. Click selects it (opens the Text
/// panel), drag moves it, the corner handle resizes it, double-click edits it.
class CaptionBox extends ConsumerStatefulWidget {
  const CaptionBox({super.key, required this.frame, required this.selected});

  /// Size of the export frame on screen, to turn drags into frame fractions.
  final Size frame;
  final bool selected;

  @override
  ConsumerState<CaptionBox> createState() => _CaptionBoxState();
}

class _CaptionBoxState extends ConsumerState<CaptionBox> {
  bool _hover = false;

  CaptionNotifier get _caption => ref.read(captionProvider.notifier);

  void _select() => ref.read(activeToolProvider.notifier).open(EditorTool.text);

  void _resize(DragUpdateDetails d, Size box) {
    final grow = (d.delta.dx + d.delta.dy) / (box.width + box.height);
    _caption.setSize(ref.read(captionProvider).size * (1 + grow * 2));
  }

  @override
  Widget build(BuildContext context) {
    final editing = ref.watch(captionProvider.select((c) => c.editing));
    final active = widget.selected || editing;
    final line = active
        ? BezelColors.accentLine
        : _hover ? const Color(0x66FFFFFF) : Colors.transparent;

    final outline = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: line, width: active ? 1.5 : 1),
      ),
      child: const SizedBox.expand(),
    );

    if (editing) {
      return Stack(children: [outline, CaptionInlineEditor(frame: widget.frame)]);
    }

    return LayoutBuilder(builder: (context, box) {
      return MouseRegion(
        cursor: SystemMouseCursors.move,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Stack(clipBehavior: Clip.none, children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _select,
            onDoubleTap: () {
              _select();
              _caption.setEditing(true);
            },
            onPanStart: (_) => _select(),
            onPanUpdate: (d) => _caption.moveBy(
                d.delta.dx / widget.frame.width, d.delta.dy / widget.frame.height),
            child: outline,
          ),
          if (active)
            Positioned(
              right: -6,
              bottom: -6,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeDownRight,
                child: GestureDetector(
                  onPanUpdate: (d) => _resize(d, box.biggest),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: BezelColors.textPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: BezelColors.accent, width: 2),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      );
    });
  }
}
