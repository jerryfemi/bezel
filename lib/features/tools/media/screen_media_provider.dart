import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../timeline/model/clips.dart';
import '../../timeline/model/tracks.dart';
import '../../timeline/state/assets_provider.dart';
import '../../timeline/state/playhead_provider.dart';
import '../../timeline/state/tracks_provider.dart';

/// What is on the device's front screen at the playhead. Empty means the
/// screen track has nothing there.
class ScreenMedia {
  const ScreenMedia({
    this.clipId, this.name, this.url, this.bytes, this.mimeType,
    this.isVideo = false, this.loading = false, this.error,
  });

  final String? clipId;
  final String? name;
  final String? url;
  final Uint8List? bytes;
  final String? mimeType;
  final bool isVideo;
  final bool loading;
  final String? error;

  bool get isEmpty => url == null;
}

/// The screen clip the Media panel edits: the selected screen clip, otherwise
/// the one under the playhead, otherwise the first one.
final screenTargetProvider = Provider<MediaClip?>((ref) {
  final tracks = ref.watch(tracksProvider);
  final screens = tracks.screens;
  if (screens.isEmpty) return null;
  final selected = ref.watch(selectedClipProvider);
  for (final c in screens) {
    if (selected?.track == TrackKind.screen && c.id == selected!.id) return c;
  }
  final length = clipLength(tracks, ref.watch(timelineProvider).duration);
  final t = ref.watch(playheadProvider).clamp(0.0, length > 0 ? length - 1e-3 : 0.0);
  for (final c in screens) {
    if (c.covers(t)) return c;
  }
  return screens.first;
});

class ScreenMediaNotifier extends Notifier<ScreenMedia> {
  bool _loading = false;

  @override
  ScreenMedia build() {
    final clip = ref.watch(screenTargetProvider);
    final asset = clip == null ? null : ref.watch(assetsProvider)[clip.assetId];
    if (asset == null) return ScreenMedia(loading: _loading);
    return ScreenMedia(
      clipId: clip!.id,
      name: asset.name,
      url: asset.url,
      bytes: asset.bytes,
      mimeType: asset.mimeType,
      isVideo: asset.isVideo,
      loading: _loading,
    );
  }

  /// Opens the file picker and puts the file on the screen: it replaces the
  /// screen clip being edited, or starts the screen track. [video] limits the
  /// picker to videos (true) or images (false); null allows both.
  Future<void> pick({bool? video}) async {
    final scene = ref.read(sceneControllerProvider);
    if (scene == null) return;
    final accept = switch (video) { true => 'video/*', false => 'image/*', null => 'image/*,video/*' };
    final file = await scene.pickFile(accept);
    if (file == null) return;
    _loading = true;
    ref.invalidateSelf();
    try {
      final asset = await ref
          .read(assetsProvider.notifier)
          .add(name: file.name, mimeType: file.type, bytes: file.bytes);
      final tracks = ref.read(tracksProvider.notifier);
      final target = ref.read(screenTargetProvider);
      if (target == null) {
        tracks.addScreen(asset, at: 0);
      } else {
        tracks.replaceScreenAsset(target.id, asset);
      }
    } finally {
      _loading = false;
      ref.invalidateSelf();
    }
  }

  /// Adds another file after the playhead on the screen track.
  Future<void> addAnother() async {
    final scene = ref.read(sceneControllerProvider);
    final file = await scene?.pickFile('image/*,video/*');
    if (file == null) return;
    final asset = await ref
        .read(assetsProvider.notifier)
        .add(name: file.name, mimeType: file.type, bytes: file.bytes);
    final clip = ref.read(tracksProvider.notifier).addScreen(asset);
    ref.read(selectedClipProvider.notifier).state = ClipRef(TrackKind.screen, clip.id);
  }
}

final screenMediaProvider =
    NotifierProvider<ScreenMediaNotifier, ScreenMedia>(ScreenMediaNotifier.new);
