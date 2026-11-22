import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../scene3d/scene_specs.dart';

/// The headline and subtitle shown beside the device.
class CaptionNotifier extends Notifier<CaptionSpec> {
  static const defaults = CaptionSpec(
    enabled: false,
    headline: 'Your app, in motion.',
    subtitle: 'Say what it does in one line.',
    side: CaptionSide.left,
  );

  @override
  CaptionSpec build() => defaults;

  void setEnabled(bool v) => _set(state.copyWith(enabled: v));
  void setHeadline(String v) => _set(state.copyWith(headline: v));
  void setSubtitle(String v) => _set(state.copyWith(subtitle: v));
  void setFont(CaptionFont v) => _set(state.copyWith(font: v));
  void setAlign(CaptionAlign v) => _set(state.copyWith(align: v));
  void setEditing(CaptionPart? part) => _set(state.copyWith(editing: () => part));

  void setSize(CaptionPart part, double v) => _set(part == CaptionPart.headline
      ? state.copyWith(size: v.clamp(0.5, 2.5))
      : state.copyWith(subSize: v.clamp(0.5, 2.5)));

  /// Picks a placement and puts the text back at its layout position.
  void setSide(CaptionSide v) => _set(state.copyWith(
        side: v,
        align: v == CaptionSide.above ? CaptionAlign.center : CaptionAlign.left,
        dx: 0, dy: 0, subDx: 0, subDy: 0,
      ));

  /// Drags a part by a fraction of the frame. Dragging the headline moves the
  /// whole caption; dragging the subtitle pulls it away on its own.
  void moveBy(CaptionPart part, double dx, double dy) => _set(part == CaptionPart.headline
      ? state.copyWith(dx: (state.dx + dx).clamp(-0.8, 0.8), dy: (state.dy + dy).clamp(-0.8, 0.8))
      : state.copyWith(
          subDx: (state.subDx + dx).clamp(-1.0, 1.0), subDy: (state.subDy + dy).clamp(-1.0, 1.0)));

  void resetPosition() => _set(state.copyWith(dx: 0, dy: 0, subDx: 0, subDy: 0));

  /// Replaces everything (opening a saved project).
  void load(CaptionSpec spec) => _set(spec);

  void apply() => ref.read(sceneControllerProvider)?.setCaption(state);

  void _set(CaptionSpec next) {
    state = next;
    apply();
  }
}

final captionProvider = NotifierProvider<CaptionNotifier, CaptionSpec>(CaptionNotifier.new);
