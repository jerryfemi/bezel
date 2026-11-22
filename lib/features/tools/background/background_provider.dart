import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/web/blob_url.dart';
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
    this.imageBytes,
  });

  final BackgroundStyle style;
  final SceneBackground swatch;
  final String? imageUrl;
  final String? imageName;

  /// The image file itself, kept so the project can be saved.
  final Uint8List? imageBytes;

  BackgroundState copyWith({BackgroundStyle? style, SceneBackground? swatch}) => BackgroundState(
      style: style ?? this.style, swatch: swatch ?? this.swatch,
      imageUrl: imageUrl, imageName: imageName, imageBytes: imageBytes);

  BackgroundSpec get spec => BackgroundSpec(
        style: style,
        colorHex: swatch.hex,
        imageUrl: style == BackgroundStyle.image ? imageUrl : null,
      );
}

class BackgroundNotifier extends Notifier<BackgroundState> {
  @override
  BackgroundState build() => const BackgroundState();

  void setStyle(BackgroundStyle style) => _set(state.copyWith(style: style));

  void setSwatch(SceneBackground swatch) => _set(state.copyWith(swatch: swatch));

  Future<void> pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    _set(BackgroundState(
        style: BackgroundStyle.image, swatch: state.swatch,
        imageUrl: file.path, imageName: file.name, imageBytes: await file.readAsBytes()));
  }

  /// Puts a saved background back (opening a project).
  void load(BackgroundStyle style, SceneBackground swatch, {String? imageName, Uint8List? imageBytes}) {
    if (imageName == null || imageBytes == null) {
      _set(BackgroundState(
          style: style == BackgroundStyle.image ? BackgroundStyle.spotlight : style, swatch: swatch));
      return;
    }
    _set(BackgroundState(
      style: style,
      swatch: swatch,
      imageName: imageName,
      imageBytes: imageBytes,
      imageUrl: blobUrlFor(imageBytes, mimeTypeFor(imageName)),
    ));
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
