import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../editor/state/scene_provider.dart';
import '../state/selected_keyframe_provider.dart';
import '../state/timeline_provider.dart';
import 'format_time.dart';
import 'keyframe_fields.dart';

/// Right panel in Motion mode: edits the selected keyframe.
class KeyframeInspector extends ConsumerWidget {
  const KeyframeInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    final key = timeline.byId(ref.watch(selectedKeyframeProvider));

    return FloatingSurface(
      radius: BezelRadius.panel,
      padding: const EdgeInsets.all(16),
      child: key == null
          ? Text(
              'Select a keyframe on the timeline, or turn the phone and press '
              '"Add keyframe" to capture its pose at the playhead.',
              style: BezelType.label.copyWith(color: BezelColors.textSecondary, height: 1.5),
            )
          : SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('Keyframe · ${formatClipTime(key.time)}', style: BezelType.title),
                const SizedBox(height: 14),
                KeyframeFields(
                  keyframe: key,
                  maxTime: timeline.duration + 3,
                  onChanged: (next) {
                    ref.read(timelineProvider.notifier).update(next);
                    // While a move loops, keep it playing so the edit is seen in motion.
                    final scene = ref.read(sceneControllerProvider);
                    if (scene != null && !scene.playing.value) scene.seek(next.time);
                  },
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => ref.read(timelineProvider.notifier).remove(key.id),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete keyframe'),
                  style: TextButton.styleFrom(foregroundColor: BezelColors.danger),
                ),
              ]),
            ),
    );
  }
}
