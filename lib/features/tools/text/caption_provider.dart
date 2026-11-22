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

  void setEnabled(bool v) => _set(enabled: v);
  void setHeadline(String v) => _set(headline: v);
  void setSubtitle(String v) => _set(subtitle: v);
  void setSide(CaptionSide v) => _set(side: v);

  void apply() => ref.read(sceneControllerProvider)?.setCaption(state);

  void _set({bool? enabled, String? headline, String? subtitle, CaptionSide? side}) {
    state = CaptionSpec(
      enabled: enabled ?? state.enabled,
      headline: headline ?? state.headline,
      subtitle: subtitle ?? state.subtitle,
      side: side ?? state.side,
    );
    apply();
  }
}

final captionProvider = NotifierProvider<CaptionNotifier, CaptionSpec>(CaptionNotifier.new);
