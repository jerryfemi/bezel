import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/web/blob_url.dart';
import '../../editor/state/scene_provider.dart';
import '../model/media_asset.dart';

/// Every media file in the open project, by id. Adding one registers it with
/// the 3D view, measures its length, then fills in its filmstrip or waveform.
class AssetsNotifier extends Notifier<Map<String, MediaAsset>> {
  int _count = 0;

  @override
  Map<String, MediaAsset> build() => const {};

  /// Adds a file. [id] and [duration] are passed when reopening a project.
  Future<MediaAsset> add({
    required String name,
    required String mimeType,
    required Uint8List bytes,
    String? id,
    double? duration,
  }) async {
    final mime = mimeTypeFor(name, reported: mimeType);
    final kind = MediaAsset.kindFor(mime);
    var asset = MediaAsset(
      id: id ?? 'a${DateTime.now().microsecondsSinceEpoch}${_count++}',
      name: name,
      mimeType: mime,
      kind: kind,
      bytes: bytes,
      url: blobUrlFor(bytes, mime),
      duration: duration,
    );
    final scene = ref.read(sceneControllerProvider);
    scene?.addAsset(asset.id, asset.url, kind.name);
    if (kind != AssetKind.image && duration == null && scene != null) {
      final measured = await scene.probeDuration(asset.id);
      if (measured > 0) asset = asset.copyWith(duration: measured);
    }
    state = {...state, asset.id: asset};
    _decorate(asset);
    return asset;
  }

  /// Thumbnails and waveforms are slow to make, so they arrive after the asset.
  Future<void> _decorate(MediaAsset asset) async {
    final scene = ref.read(sceneControllerProvider);
    if (scene == null) return;
    try {
      final filmstrip = asset.kind == AssetKind.audio ? null : await scene.filmstrip(asset.id);
      final peaks = asset.hasSound ? await scene.peaks(asset.id) : null;
      final current = state[asset.id];
      if (current == null) return;
      state = {...state, asset.id: current.copyWith(filmstrip: filmstrip, peaks: peaks)};
    } catch (_) {
      // Decorations are nice to have; the clip works without them.
    }
  }

  /// Removes every asset (switching projects).
  void clear() {
    final scene = ref.read(sceneControllerProvider);
    for (final id in state.keys) {
      scene?.removeAsset(id);
    }
    state = const {};
  }
}

final assetsProvider =
    NotifierProvider<AssetsNotifier, Map<String, MediaAsset>>(AssetsNotifier.new);
