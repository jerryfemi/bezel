import 'package:flutter/widgets.dart';

/// Draws the whole app at [scale], the way browser zoom does: layout gets a
/// window 1/scale as big, then everything is scaled down to fit. Pointer
/// input, popups and the 3D view all follow the same transform.
class UiScale extends StatelessWidget {
  const UiScale({super.key, required this.scale, required this.child});

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (scale == 1) return child;
    final media = MediaQuery.of(context);
    final size = media.size / scale;
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: size.width,
        maxWidth: size.width,
        minHeight: size.height,
        maxHeight: size.height,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: MediaQuery(
            data: media.copyWith(
              size: size,
              padding: media.padding / scale,
              viewPadding: media.viewPadding / scale,
              viewInsets: media.viewInsets / scale,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
