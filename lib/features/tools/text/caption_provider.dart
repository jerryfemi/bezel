import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../scene3d/scene_specs.dart';

/// The headline and subtitle shown beside the device.
class CaptionNotifier extends Notifier<CaptionSpec> {
  @override
  CaptionSpec build() => const CaptionSpec(
        enabled: false,
        headline: 'Your app, in motion.',
        subtitle: 'Say what it does in one line.',
        side: CaptionSide.left,
      );

  void setEnabled(bool v) => _set(state.copyWith(enabled: v));
  void setHeadline(String v) => _set(state.copyWith(headline: v));
  void setSubtitle(String v) => _set(state.copyWith(subtitle: v));
  void setFont(CaptionFont v) => _set(state.copyWith(font: v));
  void setAlign(CaptionAlign v) => _set(state.copyWith(align: v));
  void setSize(double v) => _set(state.copyWith(size: v.clamp(0.5, 2.0)));
  void setEditing(bool v) => _set(state.copyWith(editing: v));

  /// Picks a placement and puts the text back at its layout position.
  void setSide(CaptionSide v) => _set(state.copyWith(
        side: v,
        align: v == CaptionSide.above ? CaptionAlign.center : CaptionAlign.left,
        dx: 0,
        dy: 0,
      ));

  /// Drags the text by a fraction of the frame.
  void moveBy(double dx, double dy) => _set(state.copyWith(
        dx: (state.dx + dx).clamp(-0.6, 0.6),
        dy: (state.dy + dy).clamp(-0.6, 0.6),
      ));

  void resetPosition() => _set(state.copyWith(dx: 0, dy: 0));

  void apply() => ref.read(sceneControllerProvider)?.setCaption(state);

  void _set(CaptionSpec next) {
    state = next;
    apply();
  }
}

final captionProvider = NotifierProvider<CaptionNotifier, CaptionSpec>(CaptionNotifier.new);
