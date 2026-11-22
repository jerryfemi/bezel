import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/frame_shape.dart';
import '../../editor/state/project_title_provider.dart';
import '../../editor/state/scene_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../tools/background/background_provider.dart';
import '../../tools/device/device_selection.dart';
import '../../tools/light/light_provider.dart';
import '../../tools/media/screen_media_provider.dart';
import '../../tools/text/caption_provider.dart';
import '../data/project_store.dart';
import '../model/project_doc.dart';
import 'project_codec.dart';

class ProjectsState {
  const ProjectsState({this.currentId, this.projects = const []});

  final String? currentId;

  /// Most recently edited first.
  final List<ProjectDoc> projects;
}

/// The open project and the saved list. Every edit is saved shortly after it
/// happens; there is no save button.
class ProjectsNotifier extends Notifier<ProjectsState> {
  Timer? _debounce;
  bool _restoring = false;
  Uint8List? _savedScreen;
  Uint8List? _savedBackground;

  @override
  ProjectsState build() {
    for (final p in <ProviderListenable<Object?>>[
      projectTitleProvider, frameShapeProvider, backgroundProvider, captionProvider,
      lightProvider, timelineProvider, screenMediaProvider, deviceSelectionProvider,
    ]) {
      ref.listen(p, (_, __) => _schedule());
    }
    ref.onDispose(() => _debounce?.cancel());
    return ProjectsState(projects: ProjectStore.all());
  }

  /// Opens the last project (or a new one) once the 3D view has mounted.
  Future<void> start() async {
    final scene = ref.read(sceneControllerProvider);
    scene?.pose.addListener(() {
      if (!scene.playing.value) _schedule();
    });
    final last = ProjectStore.lastOpened;
    final doc = last == null ? null : ProjectStore.get(last);
    doc == null ? await newProject() : await open(doc.id);
  }

  Future<void> open(String id) async {
    final doc = ProjectStore.get(id);
    if (doc == null) return;
    await _flush();
    await _load(doc);
  }

  Future<void> newProject() async {
    await _flush();
    final now = DateTime.now().millisecondsSinceEpoch;
    await _load(ProjectDoc('p$now', {'createdAt': now}));
    await _save();
  }

  Future<void> duplicate(String id) async {
    final doc = ProjectStore.get(id);
    if (doc == null) return;
    await _flush();
    final now = DateTime.now().millisecondsSinceEpoch;
    final copy = doc.copyWith('p$now', {'title': '${doc.title} copy', 'createdAt': now, 'updatedAt': now});
    await ProjectStore.put(copy);
    for (final slot in MediaSlot.values) {
      await ProjectStore.putMedia(copy.id, slot, ProjectStore.media(id, slot));
    }
    await _load(copy);
  }

  Future<void> delete(String id) async {
    _debounce?.cancel();
    await ProjectStore.delete(id);
    final rest = ProjectStore.all();
    if (id != state.currentId) {
      state = ProjectsState(currentId: state.currentId, projects: rest);
    } else if (rest.isEmpty) {
      await newProject();
    } else {
      await _load(rest.first);
    }
  }

  Future<void> _load(ProjectDoc doc) async {
    _restoring = true;
    try {
      state = ProjectsState(currentId: doc.id, projects: state.projects);
      await restoreProject(ref, doc);
      _savedScreen = ref.read(screenMediaProvider).bytes;
      _savedBackground = ref.read(backgroundProvider).imageBytes;
      await ProjectStore.setLastOpened(doc.id);
    } finally {
      _restoring = false;
      _debounce?.cancel();
    }
    state = ProjectsState(currentId: doc.id, projects: ProjectStore.all());
  }

  void _schedule() {
    if (_restoring || state.currentId == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _save);
  }

  /// Saves now if a save is pending (before switching projects).
  Future<void> _flush() async {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      await _save();
    }
  }

  Future<void> _save() async {
    final id = state.currentId;
    if (id == null || _restoring) return;
    final old = ProjectStore.get(id);
    final now = DateTime.now().millisecondsSinceEpoch;
    final doc = ProjectDoc(id, {
      'createdAt': old?.data['createdAt'] ?? now,
      ...captureProject(ref),
      'updatedAt': now,
      'thumbnail': ref.read(sceneControllerProvider)?.snapshot() ?? old?.thumbnail,
    });
    await ProjectStore.put(doc);

    final screen = ref.read(screenMediaProvider).bytes;
    if (!identical(screen, _savedScreen)) {
      await ProjectStore.putMedia(id, MediaSlot.screen, screen);
      _savedScreen = screen;
    }
    final background = ref.read(backgroundProvider).imageBytes;
    if (!identical(background, _savedBackground)) {
      await ProjectStore.putMedia(id, MediaSlot.background, background);
      _savedBackground = background;
    }
    state = ProjectsState(currentId: id, projects: ProjectStore.all());
  }
}

final projectsProvider = NotifierProvider<ProjectsNotifier, ProjectsState>(ProjectsNotifier.new);

/// Whether the projects menu is open.
final projectsMenuOpenProvider = StateProvider<bool>((ref) => false);
