import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/frame_shape.dart';
import '../../editor/state/project_title_provider.dart';
import '../../editor/state/scene_bootstrap.dart';
import '../../editor/state/scene_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../scene3d/device_catalog.dart';
import '../../scene3d/scene_position.dart';
import '../../scene3d/scene_pose.dart';
import '../../scene3d/scene_specs.dart';
import '../../timeline/model/tracks.dart';
import '../../timeline/state/assets_provider.dart';
import '../../timeline/state/edit_history.dart';
import '../../timeline/state/playhead_provider.dart';
import '../../timeline/state/tracks_provider.dart';
import '../../tools/background/background_provider.dart';
import '../../tools/background/scene_backgrounds.dart';
import '../../tools/device/device_selection.dart';
import '../../tools/light/light_provider.dart';
import '../../tools/text/caption_provider.dart';
import '../data/project_store.dart';
import '../model/project_doc.dart';
import 'legacy_tracks.dart';

/// Reads the editor's current state into a saveable map (media bytes excluded).
Map<String, dynamic> captureProject(Ref ref) {
  final device = ref.read(deviceSelectionProvider);
  final bg = ref.read(backgroundProvider);
  final scene = ref.read(sceneControllerProvider);
  final pose = scene?.pose.value ?? startPose;
  final position = scene?.position.value ?? const ScenePosition();
  final tracks = ref.read(tracksProvider);
  final assets = ref.read(assetsProvider);
  return {
    'title': ref.read(projectTitleProvider),
    'device': device.entry.id,
    'finish': device.finishId,
    'frame': ref.read(frameShapeProvider).name,
    'pose': {'turn': pose.turn, 'tilt': pose.tilt, 'zoom': pose.zoom},
    'position': {'x': position.x, 'y': position.y},
    'background': {'style': bg.style.name, 'swatch': bg.swatch.name, 'image': bg.imageName},
    'light': ref.read(lightProvider).toMap(),
    'timeline': ref.read(timelineProvider).toMap(),
    'tracks': tracks.toMap(),
    'assets': [
      for (final id in usedAssetIds(tracks))
        if (assets[id] != null) assets[id]!.toMap(),
    ],
  };
}

/// Every media file the clips point at.
Set<String> usedAssetIds(Tracks tracks) =>
    {for (final c in tracks.screens) c.assetId, for (final c in tracks.audio) c.assetId};

/// Puts [doc] into the editor and the 3D view. Missing fields fall back to
/// the defaults, so a blank doc gives a fresh project.
Future<void> restoreProject(Ref ref, ProjectDoc doc) async {
  final d = doc.data;
  final scene = ref.read(sceneControllerProvider);
  scene?.pause();
  scene?.seek(0);
  ref.read(playheadProvider.notifier).state = 0;
  ref.read(selectedClipProvider.notifier).state = null;
  ref.read(captionEditingProvider.notifier).state = null;
  ref.read(projectTitleProvider.notifier).state = doc.title;
  ref.read(frameShapeProvider.notifier).state = _enum(FrameShape.values, d['frame'], FrameShape.landscape);

  final bg = doc.section('background') ?? const {};
  ref.read(backgroundProvider.notifier).load(
        _enum(BackgroundStyle.values, bg['style'], BackgroundStyle.spotlight),
        sceneBackgrounds.firstWhere((s) => s.name == bg['swatch'], orElse: () => defaultBackground),
        imageName: bg['image'] as String?,
        imageBytes: ProjectStore.media(doc.id, MediaSlot.background),
      );
  final light = doc.section('light');
  ref.read(lightProvider.notifier).load(
      light == null ? LightNotifier.defaults : LightSpec.fromMap(light));

  // Media files, then the clips that use them.
  final assets = ref.read(assetsProvider.notifier)..clear();
  final Tracks tracks;
  if (doc.section('tracks') != null) {
    for (final raw in (d['assets'] as List?) ?? const []) {
      final m = (raw as Map).cast<String, dynamic>();
      final bytes = ProjectStore.asset(doc.id, m['id'] as String);
      if (bytes == null) continue;
      await assets.add(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'Media',
        mimeType: m['mime'] as String? ?? '',
        bytes: bytes,
        duration: (m['duration'] as num?)?.toDouble(),
      );
    }
    final loaded = ref.read(assetsProvider);
    final saved = Tracks.fromMap(doc.section('tracks'));
    tracks = saved.copyWith(
      screens: saved.screens.where((c) => loaded.containsKey(c.assetId)).toList(),
      audio: saved.audio.where((c) => loaded.containsKey(c.assetId)).toList(),
    );
  } else {
    tracks = await tracksFromLegacy(ref, doc);
  }
  ref.read(timelineProvider.notifier).load(doc.section('timeline'));
  ref.read(tracksProvider.notifier).load(tracks);

  final entry = deviceCatalog.firstWhere((e) => e.id == doc.deviceId, orElse: () => deviceCatalog.first);
  await ref.read(deviceSelectionProvider.notifier).select(entry, finishId: d['finish'] as String?);

  final pose = doc.section('pose');
  double n(String k, double fallback) => (pose?[k] as num?)?.toDouble() ?? fallback;
  scene?.setPose(
      ScenePose(turn: n('turn', startPose.turn), tilt: n('tilt', startPose.tilt), zoom: n('zoom', 1)));
  final position = doc.section('position');
  double p(String k) => (position?[k] as num?)?.toDouble() ?? 0;
  scene?.setPosition(ScenePosition(x: p('x'), y: p('y')));
  scene?.seek(0);
  ref.read(editHistoryProvider.notifier).clear();
}

T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}
