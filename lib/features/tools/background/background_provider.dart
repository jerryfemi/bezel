import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../editor/state/scene_provider.dart';
import '../../scene3d/scene_specs.dart';
import 'scene_backgrounds.dart';

/// The scene background: a style, a base colour, and an image when used.
class BackgroundState {
  const BackgroundState({
    this.style = BackgroundStyle.spotlight,
    this.swatch = defaultBackground,
    this.imageUrl,
    this.imageName,
  });

  final BackgroundStyle style;
  final SceneBackground swatch;
  final String? imageUrl;
  final String? imageName;

  BackgroundSpec get spec => BackgroundSpec(
        style: style,
        colorHex: swatch.hex,
        imageUrl: style == BackgroundStyle.image ? imageUrl : null,
      );
}

class BackgroundNotifier extends Notifier<BackgroundState> {
  @override
  BackgroundState build() => const BackgroundState();

  void setStyle(BackgroundStyle style) => _set(BackgroundState(
      style: style, swatch: state.swatch, imageUrl: state.imageUrl, imageName: state.imageName));

  void setSwatch(SceneBackground swatch) => _set(BackgroundState(
      style: state.style, swatch: swatch, imageUrl: state.imageUrl, imageName: state.imageName));

  Future<void> pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    _set(BackgroundState(
        style: BackgroundStyle.image, swatch: state.swatch,
        imageUrl: file.path, imageName: file.name));
  }

  /// Sends the current background to the 3D view.
  Future<void> apply() async =>
      ref.read(sceneControllerProvider)?.setBackground(state.spec);

  void _set(BackgroundState next) {
    state = next;
    apply();
  }
}

final backgroundProvider =
    NotifierProvider<BackgroundNotifier, BackgroundState>(BackgroundNotifier.new);
