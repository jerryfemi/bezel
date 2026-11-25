import 'package:flutter/material.dart';

import '../../../app/theme/bezel_icons.dart';

/// The tools on the left rail, top to bottom. Each opens a panel beside it.
enum EditorTool {
  device('Device', BezelIcons.device),
  media('Media', BezelIcons.media),
  text('Text', BezelIcons.text),
  motion('Motion', BezelIcons.motionTool),
  audio('Audio', BezelIcons.audio),
  scene('Scene', BezelIcons.scene);

  const EditorTool(this.label, this.icon);

  final String label;
  final IconData icon;
}
