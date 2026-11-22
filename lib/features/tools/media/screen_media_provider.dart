import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../editor/state/scene_provider.dart';

/// What is on the device's front screen. Empty means the default wallpaper.
class ScreenMedia {
  const ScreenMedia({this.name, this.url, this.isVideo = false, this.loading = false, this.error});

  final String? name;
  final String? url;
  final bool isVideo;
  final bool loading;
  final String? error;

  bool get isEmpty => url == null;
}

class ScreenMediaNotifier extends Notifier<ScreenMedia> {
  @override
  ScreenMedia build() => const ScreenMedia();

  /// Opens the file picker. On the web the picked file's path is a blob: URL.
  Future<void> pick({required bool video}) async {
    final picker = ImagePicker();
    final file = video
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    state = ScreenMedia(name: file.name, url: file.path, isVideo: video, loading: true);
    await _apply();
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
      state = ScreenMedia(name: media.name, url: media.url, isVideo: media.isVideo);
    } catch (_) {
      state = ScreenMedia(
        name: media.name, url: media.url, isVideo: media.isVideo,
        error: 'That file could not be shown. Try a PNG, JPG, MP4 or WebM.',
      );
    }
  }
}

final screenMediaProvider =
    NotifierProvider<ScreenMediaNotifier, ScreenMedia>(ScreenMediaNotifier.new);
