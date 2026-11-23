import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/web/blob_url.dart';
import '../../editor/state/scene_provider.dart';

/// What is on the device's front screen. Empty means the default wallpaper.
class ScreenMedia {
  const ScreenMedia({
    this.name, this.url, this.bytes, this.mimeType,
    this.isVideo = false, this.loading = false, this.error,
  });

  final String? name;
  final String? url;

  /// The file itself, kept so the project can be saved.
  final Uint8List? bytes;
  final String? mimeType;
  final bool isVideo;
  final bool loading;
  final String? error;

  bool get isEmpty => url == null;

  ScreenMedia settled({String? error}) => ScreenMedia(
      name: name, url: url, bytes: bytes, mimeType: mimeType, isVideo: isVideo, error: error);
}

class ScreenMediaNotifier extends Notifier<ScreenMedia> {
  @override
  ScreenMedia build() => const ScreenMedia();

  /// Opens the file picker. On the web the picked file's path is a blob: URL.
  /// With [video] null, any image or video can be picked (tapping the screen).
  Future<void> pick({bool? video}) async {
    final picker = ImagePicker();
    final file = switch (video) {
      true => await picker.pickVideo(source: ImageSource.gallery),
      false => await picker.pickImage(source: ImageSource.gallery),
      null => await picker.pickMedia(),
    };
    if (file == null) return;
    video ??= mimeTypeFor(file.name, reported: file.mimeType).startsWith('video/');
    final bytes = await file.readAsBytes();
    state = ScreenMedia(
      name: file.name, url: file.path, bytes: bytes,
      mimeType: mimeTypeFor(file.name, reported: file.mimeType),
      isVideo: video, loading: true,
    );
    await _apply();
  }

  /// Puts saved media back (opening a project). Null clears the screen.
  Future<void> load({String? name, Uint8List? bytes, String? mimeType, bool isVideo = false}) async {
    if (bytes == null || name == null) {
      state = const ScreenMedia();
      return;
    }
    final mime = mimeTypeFor(name, reported: mimeType);
    state = ScreenMedia(
        name: name, url: blobUrlFor(bytes, mime), bytes: bytes, mimeType: mime,
        isVideo: isVideo, loading: true);
  }

  /// Puts the current media back after the device changes.
  Future<void> reapply() async {
    if (!state.isEmpty) await _apply();
  }

  Future<void> _apply() async {
    final scene = ref.read(sceneControllerProvider);
    final media = state;
    if (scene == null || media.url == null) return;
    try {
      media.isVideo
          ? await scene.setScreenVideo(media.url!)
          : await scene.setScreenImage(media.url!);
      state = media.settled();
    } catch (_) {
      state = media.settled(error: 'That file could not be shown. Try a PNG, JPG, MP4 or WebM.');
    }
  }
}

final screenMediaProvider =
    NotifierProvider<ScreenMediaNotifier, ScreenMedia>(ScreenMediaNotifier.new);
