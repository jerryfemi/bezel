import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../scene3d/device_catalog.dart';
import '../../scene3d/device_profile.dart';
import '../media/screen_media_provider.dart';

/// The device on the canvas, its finish, and whether it is still loading.
class DeviceSelection {
  const DeviceSelection({
    required this.entry,
    this.profile,
    this.finishId,
    this.loading = false,
    this.error,
  });

  final DeviceEntry entry;
  final DeviceProfile? profile;
  final String? finishId;
  final bool loading;
  final String? error;

  DeviceFinish? get finish {
    for (final f in profile?.finishes ?? const <DeviceFinish>[]) {
      if (f.id == finishId) return f;
    }
    return null;
  }
}

class DeviceSelectionNotifier extends Notifier<DeviceSelection> {
  @override
  DeviceSelection build() => DeviceSelection(entry: deviceCatalog.first, loading: true);

  /// Loads [entry] into the 3D view, then puts the user's media back on it.
  /// [finishId] picks a finish (when opening a saved project).
  Future<void> select(DeviceEntry entry, {String? finishId}) async {
    final scene = ref.read(sceneControllerProvider);
    state = DeviceSelection(entry: entry, loading: true);
    if (scene == null) return;
    try {
      final profile = await scene.loadDevice(entry.baseUrl, finishId: finishId);
      final finish = profile.finishes.any((f) => f.id == finishId) ? finishId : profile.defaultFinish;
      state = DeviceSelection(entry: entry, profile: profile, finishId: finish);
      await ref.read(screenMediaProvider.notifier).reapply();
    } catch (e) {
      state = DeviceSelection(entry: entry, error: 'Could not load ${entry.label}.');
    }
  }

  void setFinish(String finishId) {
    ref.read(sceneControllerProvider)?.setFinish(finishId);
    state = DeviceSelection(entry: state.entry, profile: state.profile, finishId: finishId);
  }
}

final deviceSelectionProvider =
    NotifierProvider<DeviceSelectionNotifier, DeviceSelection>(DeviceSelectionNotifier.new);
