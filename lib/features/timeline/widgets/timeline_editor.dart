import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_motion.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../editor/state/editor_layout.dart';
import 'timeline_canvas.dart';
import 'timeline_toolbar.dart';
import 'track_headers.dart';
import 'track_style.dart';

/// The docked timeline along the bottom: captions, screen, motion and audio
/// on stacked tracks. Folds down to its toolbar to give the canvas room.
class TimelineEditor extends ConsumerWidget {
  const TimelineEditor({super.key});

  static const _toolbar = 40.0;
  static const _padding = 16.0;
  static double get _full => _toolbar + 8 + TrackStyle.rulerHeight + TrackStyle.rowsHeight + 8;

  static double heightFor({required bool folded}) => (folded ? _toolbar : _full) + _padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folded = ref.watch(timelineFoldedProvider);
    return FloatingSurface(
      radius: BezelRadius.panel,
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 10),
      child: AnimatedContainer(
        duration: BezelMotion.of(context, BezelMotion.panel),
        curve: BezelMotion.settle,
        height: heightFor(folded: folded) - _padding,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: _full,
            maxHeight: _full,
            child: const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TimelineToolbar(),
              SizedBox(height: 8),
              Expanded(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TrackHeaders(),
                  Expanded(child: TimelineCanvas()),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
