import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/pointer_shield.dart';
import '../../scene3d/scene_specs.dart';
import '../../tools/text/caption_provider.dart';
import '../state/active_tool_provider.dart';
import '../state/editor_tool.dart';
import '../state/scene_provider.dart';
import 'caption_box.dart';

/// Lays hit boxes over the headline and subtitle drawn in the 3D view, so
/// each can be selected, dragged, resized and edited right on the canvas.
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
      Rect onScreen(Rect r) => Rect.fromLTWH(r.left * frame.width, r.top * frame.height,
              r.width * frame.width, r.height * frame.height)
          .inflate(CaptionBox.pad);

      return ValueListenableBuilder(
        valueListenable: scene.captionBounds,
        builder: (context, bounds, _) {
          if (bounds == null) return const SizedBox.shrink();
          return Stack(children: [
            for (final (part, rect) in [
              (CaptionPart.headline, bounds.head),
              (CaptionPart.subtitle, bounds.sub),
            ])
              if (rect != null)
                Positioned.fromRect(
                  rect: onScreen(rect),
                  child: PointerShield(
                    child: CaptionBox(part: part, frame: frame, selected: selected),
                  ),
                ),
          ]);
        },
      );
    });
  }
}
