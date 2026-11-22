import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../scene3d/scene_specs.dart';

class LightNotifier extends Notifier<LightSpec> {
  static const defaults = LightSpec(angle: 315, intensity: 0.6, reflections: true);

  @override
  LightSpec build() => defaults;

  void reset() => _set(defaults);

  void setAngle(double v) =>
      _set(LightSpec(angle: v, intensity: state.intensity, reflections: state.reflections));
  void setIntensity(double v) =>
      _set(LightSpec(angle: state.angle, intensity: v, reflections: state.reflections));
  void setReflections(bool v) =>
      _set(LightSpec(angle: state.angle, intensity: state.intensity, reflections: v));

  void apply() => ref.read(sceneControllerProvider)?.setLight(state);

  void _set(LightSpec next) {
    state = next;
    apply();
  }
}

final lightProvider = NotifierProvider<LightNotifier, LightSpec>(LightNotifier.new);
