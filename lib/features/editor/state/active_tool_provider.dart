import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'editor_tool.dart';

/// Which tool panel is open above the dock, if any.
class ActiveToolNotifier extends Notifier<EditorTool?> {
  @override
  EditorTool? build() => null;

  /// Opens [tool], or closes it if it is already open.
  void toggle(EditorTool tool) => state = state == tool ? null : tool;

  void open(EditorTool tool) => state = tool;

  void close() => state = null;
}

final activeToolProvider =
    NotifierProvider<ActiveToolNotifier, EditorTool?>(ActiveToolNotifier.new);
