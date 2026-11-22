import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';

import '../model/project_doc.dart';

/// Where a project's media files are kept.
enum MediaSlot { screen, background }

/// Saved projects in the browser's storage (IndexedDB, through Hive).
/// Project settings and media files live in separate boxes so the project
/// list loads without reading any videos.
class ProjectStore {
  const ProjectStore._();

  static const _docs = 'bezel_projects';
  static const _media = 'bezel_media';
  static const _prefs = 'bezel_prefs';

  static bool _ready = false;

  /// False if the browser refused storage (e.g. some private windows).
  static bool get available => _ready;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox<String>(_docs);
      await Hive.openBox<Uint8List>(_media);
      await Hive.openBox<String>(_prefs);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  static Box<String> get _docBox => Hive.box<String>(_docs);
  static Box<Uint8List> get _mediaBox => Hive.box<Uint8List>(_media);
  static Box<String> get _prefBox => Hive.box<String>(_prefs);

  /// Every project, most recently edited first.
  static List<ProjectDoc> all() {
    if (!_ready) return const [];
    final docs = [
      for (final key in _docBox.keys) ProjectDoc.decode(key as String, _docBox.get(key)!),
    ];
    return docs..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static ProjectDoc? get(String id) {
    final json = _ready ? _docBox.get(id) : null;
    return json == null ? null : ProjectDoc.decode(id, json);
  }

  static Future<void> put(ProjectDoc doc) async {
    if (_ready) await _docBox.put(doc.id, doc.encode());
  }

  static Uint8List? media(String id, MediaSlot slot) =>
      _ready ? _mediaBox.get('$id/${slot.name}') : null;

  /// Saves [bytes] for [slot], or removes it when null.
  static Future<void> putMedia(String id, MediaSlot slot, Uint8List? bytes) async {
    if (!_ready) return;
    final key = '$id/${slot.name}';
    bytes == null ? await _mediaBox.delete(key) : await _mediaBox.put(key, bytes);
  }

  static Future<void> delete(String id) async {
    if (!_ready) return;
    await _docBox.delete(id);
    for (final slot in MediaSlot.values) {
      await _mediaBox.delete('$id/${slot.name}');
    }
  }

  static String? get lastOpened => _ready ? _prefBox.get('last') : null;

  static Future<void> setLastOpened(String id) async {
    if (_ready) await _prefBox.put('last', id);
  }
}
