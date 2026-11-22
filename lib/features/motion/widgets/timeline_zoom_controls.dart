import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../state/timeline_zoom_provider.dart';

/// − 100% + and Fit, for the timeline's zoom.
class TimelineZoomControls extends ConsumerWidget {
  const TimelineZoomControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoom = ref.watch(timelineZoomProvider);
    final notifier = ref.read(timelineZoomProvider.notifier);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        tooltip: 'Zoom out',
        onPressed: zoom > TimelineZoomNotifier.min ? () => notifier.scaleBy(1 / 1.5) : null,
        icon: const Icon(Icons.remove, size: 16),
      ),
      SizedBox(
        width: 48,
        child: Text('${(zoom * 100).round()}%',
            textAlign: TextAlign.center, style: BezelType.mono),
      ),
      IconButton(
        tooltip: 'Zoom in',
        onPressed: zoom < TimelineZoomNotifier.max ? () => notifier.scaleBy(1.5) : null,
        icon: const Icon(Icons.add, size: 16),
      ),
      TextButton(
        onPressed: zoom == TimelineZoomNotifier.min ? null : notifier.fit,
        style: TextButton.styleFrom(foregroundColor: BezelColors.accentLine),
        child: const Text('Fit'),
      ),
    ]);
  }
}
