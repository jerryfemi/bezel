import 'package:flutter/material.dart';

/// The tools in the bottom-right dock, in display order.
enum EditorTool {
  device('Device', Icons.phone_iphone_outlined),
  media('Media', Icons.play_circle_outline),
  pose('Pose', Icons.threed_rotation),
  background('Background', Icons.wallpaper_outlined),
  text('Text', Icons.text_fields),
  light('Light', Icons.light_mode_outlined);

  const EditorTool(this.label, this.icon);

  final String label;
  final IconData icon;
}
