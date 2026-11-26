import 'package:flutter/material.dart';

import '../../../app/theme/bezel_icons.dart';
import '../model/clips.dart';

/// How each timeline row looks: its height, name, icon and clip colour.
class TrackStyle {
  const TrackStyle(this.label, this.icon, this.height, this.fill, this.edge);

  final String label;
  final IconData icon;
  final double height;

  /// Clip body and its brighter outline.
  final Color fill;
  final Color edge;

  static const rulerHeight = 26.0;
  static const gap = 6.0;
  static const headerWidth = 150.0;

  /// Top to bottom, like a video editor: text over picture over motion over sound.
  static const order = [TrackKind.caption, TrackKind.screen, TrackKind.motion, TrackKind.audio];

  static TrackStyle of(TrackKind kind) => switch (kind) {
        TrackKind.caption => const TrackStyle(
            'Captions', BezelIcons.caption, 32, Color(0xFF5B3E12), Color(0xFFE9A83B)),
        TrackKind.screen => const TrackStyle(
            'Screen', BezelIcons.screenClip, 48, Color(0xFF123F3C), Color(0xFF3CC4B5)),
        TrackKind.motion => const TrackStyle(
            'Motion', BezelIcons.motion, 32, Color(0xFF1A2A55), Color(0xFF8FB0FF)),
        TrackKind.audio => const TrackStyle(
            'Audio', BezelIcons.audio, 40, Color(0xFF173A24), Color(0xFF52C77E)),
      };

  /// Distance from the top of the tracks area (below the ruler) to row [kind].
  static double topOf(TrackKind kind) {
    var y = 0.0;
    for (final k in order) {
      if (k == kind) return y;
      y += of(k).height + gap;
    }
    return y;
  }

  static double get rowsHeight =>
      order.fold(0.0, (sum, k) => sum + of(k).height + gap);
}
