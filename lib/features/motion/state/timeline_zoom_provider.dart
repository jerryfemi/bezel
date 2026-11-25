import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the timeline is zoomed in: 1 = the whole clip fits (100%).
class TimelineZoomNotifier extends Notifier<double> {
  static const min = 1.0;
  static const max = 20.0;

  @override
  double build() => min;

  void set(double zoom) => state = zoom.clamp(min, max).toDouble();
  void scaleBy(double factor) => set(state * factor);
  void fit() => state = min;
}

final timelineZoomProvider =
    NotifierProvider<TimelineZoomNotifier, double>(TimelineZoomNotifier.new);
