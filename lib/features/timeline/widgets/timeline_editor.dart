import 'package:flutter/material.dart';

import '../../../app/theme/bezel_metrics.dart';
import '../../../core/widgets/floating_surface.dart';
import 'timeline_canvas.dart';
import 'timeline_toolbar.dart';
import 'track_headers.dart';
import 'track_style.dart';

/// The docked, CapCut-style timeline: captions, screen, motion and audio on
/// stacked tracks. Every block can be moved, trimmed at either edge, split
/// at the playhead (S) and deleted.
class TimelineEditor extends StatelessWidget {
  const TimelineEditor({super.key});

  static double get height => 40 + 8 + TrackStyle.rulerHeight + TrackStyle.rowsHeight + 24;

  @override
  Widget build(BuildContext context) {
    return FloatingSurface(
      radius: BezelRadius.panel,
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 10),
      child: SizedBox(
        height: height - 16,
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
    );
  }
}
