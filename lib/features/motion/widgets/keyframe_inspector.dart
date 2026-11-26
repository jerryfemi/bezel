import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../editor/state/scene_provider.dart';
import '../../timeline/widgets/inspector/inspector_panel.dart';
import '../state/selected_keyframe_provider.dart';
import '../state/timeline_provider.dart';
import 'format_time.dart';
import 'keyframe_fields.dart';

/// The right panel for the selected keyframe on the motion track.
class KeyframeInspector extends ConsumerWidget {
  const KeyframeInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    final key = timeline.byId(ref.watch(selectedKeyframeProvider));
    if (key == null) {
      return InspectorPanel(
        title: 'Motion',
        child: Text('This keyframe was removed.', style: BezelType.caption),
      );
    }

    return InspectorPanel(
      title: 'Keyframe',
      subtitle: 'At ${formatClipTime(key.time)}',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ChipButton(
            icon: Icons.delete_outline,
            label: 'Delete keyframe',
            onTap: () => ref.read(timelineProvider.notifier).remove(key.id),
          ),
        ),
      ]),
    );
  }
}
