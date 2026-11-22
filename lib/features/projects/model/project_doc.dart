import 'dart:convert';

/// One saved project: everything needed to rebuild the editor, except the
/// media files themselves (those live in the media box, keyed by [id]).
/// Stored as JSON so old saves still load when fields are added.
class ProjectDoc {
  const ProjectDoc(this.id, this.data);

  final String id;

  /// The JSON object written by `captureProject`.
  final Map<String, dynamic> data;

  String get title => data['title'] as String? ?? 'Untitled clip';
  String get deviceId => data['device'] as String? ?? '';
  DateTime get updatedAt => DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int? ?? 0);

  /// A small JPEG data URL of the frame, if one was captured.
  String? get thumbnail => data['thumbnail'] as String?;

  Map<String, dynamic>? section(String key) => (data[key] as Map?)?.cast<String, dynamic>();

  ProjectDoc copyWith(String id, Map<String, dynamic> changes) =>
      ProjectDoc(id, {...data, ...changes});

  String encode() => jsonEncode(data);

  static ProjectDoc decode(String id, String json) =>
      ProjectDoc(id, (jsonDecode(json) as Map).cast<String, dynamic>());
}
