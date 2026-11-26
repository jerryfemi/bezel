import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/bezel_motion.dart';
import '../timeline/widgets/clip_inspector.dart';
import 'settings/project_settings_panel.dart';
import 'state/editor_layout.dart';

/// The right panel: settings for whatever is selected on the timeline, or
/// the project's own settings when nothing is.
class InspectorHost extends ConsumerWidget {
  const InspectorHost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(hasSelectionProvider);
    return AnimatedSwitcher(
      duration: BezelMotion.of(context, const Duration(milliseconds: 160)),
      layoutBuilder: (current, previous) =>
          Stack(fit: StackFit.expand, children: [...previous, if (current != null) current]),
      child: selected
          ? const ClipInspector(key: ValueKey('clip'))
          : const ProjectSettingsPanel(key: ValueKey('project')),
    );
  }
}
