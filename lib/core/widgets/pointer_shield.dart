import 'package:flutter/widgets.dart';

/// Stops browser pointer events from reaching the 3D view underneath.
///
/// On Flutter web the 3D view is an HTML element, and the browser delivers
/// clicks and drags straight to it even where Flutter draws on top. An
/// invisible HTML element behind [child] catches those events first.
class PointerShield extends StatelessWidget {
  const PointerShield({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: HtmlElementView.fromTagName(tagName: 'div', isVisible: false),
      ),
      child,
    ]);
  }
}
