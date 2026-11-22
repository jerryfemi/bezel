import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../scene3d/scene_specs.dart';
import '../../tools/text/caption_provider.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';
import 'caption_inline_editor.dart';

/// One caption part's outline on the canvas. Click selects it (opens the Text
/// panel), drag moves it, the corner handle resizes it, double-click edits it.
/// Dragging the headline moves the whole caption; the subtitle moves alone.
class CaptionBox extends ConsumerStatefulWidget {
  const CaptionBox({super.key, required this.part, required this.frame, required this.selected});

  /// Space kept around the text inside the box.
  static const pad = 8.0;

  final CaptionPart part;

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
    final c = ref.read(captionProvider);
    final now = widget.part == CaptionPart.headline ? c.size : c.subSize;
    final grow = (d.delta.dx + d.delta.dy) / (box.width + box.height);
    _caption.setSize(widget.part, now * (1 + grow * 2));
  }

  @override
  Widget build(BuildContext context) {
    final editing = ref.watch(captionProvider.select((c) => c.editing)) == widget.part;
    final active = widget.selected || editing;
    final line = editing || (active && _hover)
        ? BezelColors.accentLine
        : active
            ? const Color(0x998FB0FF)
            : _hover ? const Color(0x66FFFFFF) : Colors.transparent;

    final outline = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: line, width: editing ? 1.5 : 1),
      ),
      child: const SizedBox.expand(),
    );

    if (editing) {
      return Stack(children: [outline, CaptionInlineEditor(part: widget.part, frame: widget.frame)]);
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
              _caption.setEditing(widget.part);
            },
            onPanStart: (_) => _select(),
            onPanUpdate: (d) => _caption.moveBy(
                widget.part, d.delta.dx / widget.frame.width, d.delta.dy / widget.frame.height),
            child: outline,
          ),
          if (active)
            Positioned(
              right: -5,
              bottom: -5,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeDownRight,
                child: GestureDetector(
                  onPanUpdate: (d) => _resize(d, box.biggest),
                  child: Container(
                    width: 10,
                    height: 10,
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
