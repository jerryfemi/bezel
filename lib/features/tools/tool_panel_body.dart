import 'package:flutter/material.dart';

import '../../core/widgets/panel_section.dart';
import '../editor/state/editor_tool.dart';
import '../motion/widgets/preset_list_panel.dart';
import 'audio/audio_panel.dart';
import 'background/background_panel.dart';
import 'device/device_panel.dart';
import 'light/light_panel.dart';
import 'media/media_library_panel.dart';
import 'pose/pose_panel.dart';
import 'text/text_panel.dart';

/// Picks the panel content for a rail tool.
class ToolPanelBody extends StatelessWidget {
  const ToolPanelBody({super.key, required this.tool});

  final EditorTool tool;

  @override
  Widget build(BuildContext context) {
    return switch (tool) {
      EditorTool.device => const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DevicePanel(),
          SizedBox(height: 22),
          PanelSection(title: 'Angle', child: PosePanel()),
        ]),
      EditorTool.media => const MediaLibraryPanel(),
      EditorTool.text => const TextPanel(),
      EditorTool.motion => const PresetListPanel(),
      EditorTool.audio => const AudioPanel(),
      EditorTool.scene => const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          BackgroundPanel(),
          SizedBox(height: 22),
          PanelSection(title: 'Light', child: LightPanel()),
        ]),
    };
  }
}
