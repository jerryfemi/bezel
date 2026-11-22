import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../scene3d/scene_view.dart';
import '../state/frame_shape.dart';
import '../state/scene_bootstrap.dart';
import 'caption_overlay.dart';

/// The export frame: the 3D view, sized to the chosen shape and centred.
class SceneFrame extends ConsumerWidget {
  const SceneFrame({super.key});

  static const _radius = 12.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shape = ref.watch(frameShapeProvider);
    return LayoutBuilder(builder: (context, box) {
      final size = _fit(box.biggest, shape.aspect);
      return Center(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: BezelColors.strokeStrong),
            boxShadow: const [
              BoxShadow(color: Color(0x73000000), blurRadius: 80, offset: Offset(0, 30)),
            ],
          ),
          child: Stack(children: [
            Positioned.fill(
              child: SceneView(
                cornerRadius: _radius,
                onReady: (scene) => attachScene(ref, scene),
              ),
            ),
            const Positioned.fill(child: CaptionOverlay()),
          ]),
        ),
      );
    });
  }

  /// Largest size of [aspect] (width / height) that fits in [space].
  static Size _fit(Size space, double aspect) {
    final width = (space.height * aspect).clamp(0.0, space.width).toDouble();
    return Size(width, width / aspect);
  }
}
