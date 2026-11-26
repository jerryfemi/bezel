import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/panel_section.dart';
import '../../motion/state/timeline_provider.dart';
import '../../motion/widgets/format_time.dart';
import '../../timeline/model/tracks.dart';
import '../../timeline/state/tracks_provider.dart';
import '../../timeline/widgets/inspector/inspector_panel.dart';
import '../../tools/background/background_panel.dart';
import 'frame_size_list.dart';

/// The right panel when nothing is selected: the video's size, length and
/// background.
class ProjectSettingsPanel extends ConsumerWidget {
  const ProjectSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final length = clipLength(ref.watch(tracksProvider), ref.watch(timelineProvider).duration);
    return InspectorPanel(
      title: 'Video',
      subtitle: 'Select a clip on the timeline to edit it',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const PanelSection(title: 'Size', child: FrameSizeList()),
        const SizedBox(height: 20),
        PanelSection(
          title: 'Length',
          trailing: Text(length > 0 ? formatClipTime(length) : '—', style: BezelType.mono),
          child: Text(
            length > 0
                ? 'Set by your clips and motion. Drag the end of the last clip to change it.'
                : 'A still picture. Add a recording, captions or motion to make a video.',
            style: BezelType.caption.copyWith(color: BezelColors.textSecondary, height: 1.45),
          ),
        ),
        const SizedBox(height: 20),
        const PanelSection(title: 'Background', child: BackgroundPanel()),
      ]),
    );
  }
}
