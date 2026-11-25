import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scene3d/scene_specs.dart';
import '../../timeline/model/clips.dart';
import '../../timeline/model/tracks.dart';
import '../../timeline/state/assets_provider.dart';
import '../data/project_store.dart';
import '../model/project_doc.dart';

/// Builds tracks for a project saved before the timeline had tracks: its one
/// screen file and its one caption become clips. A screen recording that was
/// shorter than the motion used to loop, so it repeats to keep the same look.
Future<Tracks> tracksFromLegacy(Ref ref, ProjectDoc doc) async {
  final keys = (doc.section('timeline')?['keyframes'] as List?) ?? const [];
  final motionEnd = keys.isEmpty ? 0.0 : ((keys.last as Map)['time'] as num).toDouble();
  var length = motionEnd > 0 ? motionEnd : 3.0;

  final screens = <MediaClip>[];
  final screen = doc.section('screen');
  final bytes = ProjectStore.media(doc.id, MediaSlot.screen);
  if (screen != null && bytes != null) {
    final asset = await ref.read(assetsProvider.notifier).add(
          name: screen['name'] as String? ?? 'Screen',
          mimeType: screen['mime'] as String? ?? '',
          bytes: bytes,
        );
    // With no motion, the clip used to be as long as the recording.
    if (motionEnd <= 0 && asset.duration != null) length = asset.duration!;
    final each = asset.duration ?? length;
    var start = 0.0;
    var n = 0;
    while (start < length - 0.01 && n < 50) {
      final end = math.min(start + each, length);
      screens.add(MediaClip(id: 's_legacy$n', start: start, end: end, assetId: asset.id));
      start = end;
      n++;
    }
  }

  final caption = doc.section('caption');
  final captions = <CaptionClip>[
    if (caption != null && caption['enabled'] == true)
      CaptionClip(
        id: 'c_legacy',
        start: 0,
        end: math.max(length, screens.isEmpty ? 0.0 : screens.last.end),
        spec: CaptionSpec.fromMap(caption).copyWith(enabled: true),
      ),
  ];
  return Tracks(captions: captions, screens: screens);
}
