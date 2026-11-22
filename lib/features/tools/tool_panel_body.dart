import 'package:flutter/material.dart';

import '../editor/state/editor_tool.dart';
import 'background/background_panel.dart';
import 'device/device_panel.dart';
import 'light/light_panel.dart';
import 'media/media_panel.dart';
import 'pose/pose_panel.dart';
import 'text/text_panel.dart';

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
      EditorTool.text => const TextPanel(),
      EditorTool.light => const LightPanel(),
    };
  }
}
