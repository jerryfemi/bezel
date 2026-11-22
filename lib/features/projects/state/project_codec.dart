import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/frame_shape.dart';
import '../../editor/state/project_title_provider.dart';
import '../../editor/state/scene_bootstrap.dart';
import '../../editor/state/scene_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../scene3d/device_catalog.dart';
import '../../scene3d/scene_pose.dart';
import '../../scene3d/scene_specs.dart';
import '../../tools/background/background_provider.dart';
import '../../tools/background/scene_backgrounds.dart';
import '../../tools/device/device_selection.dart';
import '../../tools/light/light_provider.dart';
import '../../tools/media/screen_media_provider.dart';
import '../../tools/text/caption_provider.dart';
import '../data/project_store.dart';
import '../model/project_doc.dart';

/// Reads the editor's current state into a saveable map (media excluded).
Map<String, dynamic> captureProject(Ref ref) {
  final device = ref.read(deviceSelectionProvider);
  final bg = ref.read(backgroundProvider);
  final screen = ref.read(screenMediaProvider);
  final pose = ref.read(sceneControllerProvider)?.pose.value ?? startPose;
  return {
    'title': ref.read(projectTitleProvider),
    'device': device.entry.id,
    'finish': device.finishId,
    'frame': ref.read(frameShapeProvider).name,
    'pose': {'turn': pose.turn, 'tilt': pose.tilt, 'zoom': pose.zoom},
    'background': {'style': bg.style.name, 'swatch': bg.swatch.name, 'image': bg.imageName},
    'caption': ref.read(captionProvider).toMap(),
    'light': ref.read(lightProvider).toMap(),
    'timeline': ref.read(timelineProvider).toMap(),
    'screen': screen.isEmpty
        ? null
        : {'name': screen.name, 'mime': screen.mimeType, 'video': screen.isVideo},
  };
}

/// Puts [doc] into the editor and the 3D view. Missing fields fall back to
/// the defaults, so a blank doc gives a fresh project.
Future<void> restoreProject(Ref ref, ProjectDoc doc) async {
  final d = doc.data;
  ref.read(projectTitleProvider.notifier).state = doc.title;
  ref.read(frameShapeProvider.notifier).state = _enum(FrameShape.values, d['frame'], FrameShape.landscape);

  final bg = doc.section('background') ?? const {};
  ref.read(backgroundProvider.notifier).load(
        _enum(BackgroundStyle.values, bg['style'], BackgroundStyle.spotlight),
        sceneBackgrounds.firstWhere((s) => s.name == bg['swatch'], orElse: () => defaultBackground),
        imageName: bg['image'] as String?,
        imageBytes: ProjectStore.media(doc.id, MediaSlot.background),
      );

  final caption = doc.section('caption');
  ref.read(captionProvider.notifier).load(
      caption == null ? CaptionNotifier.defaults : CaptionSpec.fromMap(caption));
  final light = doc.section('light');
  ref.read(lightProvider.notifier).load(
      light == null ? LightNotifier.defaults : LightSpec.fromMap(light));

  final screen = doc.section('screen');
  await ref.read(screenMediaProvider.notifier).load(
        name: screen?['name'] as String?,
        mimeType: screen?['mime'] as String?,
        isVideo: screen?['video'] == true,
        bytes: screen == null ? null : ProjectStore.media(doc.id, MediaSlot.screen),
      );

  final entry = deviceCatalog.firstWhere((e) => e.id == doc.deviceId, orElse: () => deviceCatalog.first);
  await ref.read(deviceSelectionProvider.notifier).select(entry, finishId: d['finish'] as String?);

  final pose = doc.section('pose');
  double n(String k, double fallback) => (pose?[k] as num?)?.toDouble() ?? fallback;
  ref.read(sceneControllerProvider)?.setPose(
      ScenePose(turn: n('turn', startPose.turn), tilt: n('tilt', startPose.tilt), zoom: n('zoom', 1)));
  ref.read(timelineProvider.notifier).load(doc.section('timeline'));
}

T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
