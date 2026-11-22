import 'package:flutter/widgets.dart';

/// Motion tokens. Critically damped feel: quick start, no overshoot.
abstract final class BezelMotion {
  static const press = Duration(milliseconds: 90);
  static const panel = Duration(milliseconds: 240);
  static const settle = Cubic(0.2, 0.9, 0.25, 1.0);

  /// Honors the system "reduce motion" setting.
  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) == true ? Duration.zero : d;
}
