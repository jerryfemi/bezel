import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/pointer_shield.dart';
import '../../tools/text/caption_provider.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';
import '../state/scene_provider.dart';
import 'caption_box.dart';

/// Lays a hit box over the caption drawn in the 3D view, so the text can be
/// selected, dragged, resized and edited right on the canvas.
class CaptionOverlay extends ConsumerWidget {
  const CaptionOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(sceneControllerProvider);
    final enabled = ref.watch(captionProvider.select((c) => c.enabled));
    if (scene == null || !enabled) return const SizedBox.shrink();
    final selected = ref.watch(activeToolProvider) == EditorTool.text;

    return LayoutBuilder(builder: (context, box) {
      final frame = box.biggest;
      return ValueListenableBuilder<Rect?>(
        valueListenable: scene.captionBounds,
        builder: (context, b, _) {
          if (b == null) return const SizedBox.shrink();
          final rect = Rect.fromLTWH(
                  b.left * frame.width, b.top * frame.height, b.width * frame.width, b.height * frame.height)
              .inflate(10);
          return Stack(children: [
            Positioned.fromRect(
              rect: rect,
              child: PointerShield(child: CaptionBox(frame: frame, selected: selected)),
            ),
          ]);
        },
      );
    });
  }
}
