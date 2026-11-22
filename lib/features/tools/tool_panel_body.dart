import 'package:flutter/material.dart';

import '../editor/state/editor_tool.dart';
import 'background/background_panel.dart';
import 'coming_soon_panel.dart';
import 'device/device_panel.dart';
import 'media/media_panel.dart';
import 'pose/pose_panel.dart';

/// Picks the panel content for a tool.
class ToolPanelBody extends StatelessWidget {
  const ToolPanelBody({super.key, required this.tool});

  final EditorTool tool;

  @override
  Widget build(BuildContext context) {
    return switch (tool) {
      EditorTool.device => const DevicePanel(),
      EditorTool.media => const MediaPanel(),
      EditorTool.pose => const PosePanel(),
      EditorTool.background => const BackgroundPanel(),
      EditorTool.text => const ComingSoonPanel(
          message: 'Add a headline and subtitle beside the device. Coming in the next phase.'),
      EditorTool.light => const ComingSoonPanel(
          message: 'Light direction, strength and reflections. Coming in the next phase.'),
    };
  }
}
