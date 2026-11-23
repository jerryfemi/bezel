import 'package:flutter/material.dart';

import '../../../app/theme/bezel_icons.dart';

/// The tools in the bottom dock, in display order.
enum EditorTool {
  device('Device', BezelIcons.device),
  media('Media', BezelIcons.media),
  pose('Pose', BezelIcons.pose),
  background('Background', BezelIcons.background),
  text('Text', BezelIcons.text),
  light('Light', BezelIcons.light);

  const EditorTool(this.label, this.icon);

  final String label;
  final IconData icon;
}
