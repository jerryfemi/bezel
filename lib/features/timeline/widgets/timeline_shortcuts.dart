import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/editor_mode_provider.dart';
import '../state/playhead_provider.dart';
import '../state/timeline_actions.dart';

/// Editor keyboard shortcuts, listened for app-wide so they work whatever
/// was clicked last (the 3D view takes focus away from Flutter). Ignored while
/// typing in a text field.
///
/// Space play/pause · Ctrl/⌘+Z undo · Ctrl/⌘+Shift+Z or Ctrl+Y redo ·
/// in Timeline mode: S split · Delete/Backspace delete · ←/→ step a frame
/// (with Shift: a second).
class TimelineShortcuts extends ConsumerStatefulWidget {
  const TimelineShortcuts({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TimelineShortcuts> createState() => _TimelineShortcutsState();
}

class _TimelineShortcutsState extends ConsumerState<TimelineShortcuts> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool get _typing {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;
    return context.widget is EditableText || context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  bool _onKey(KeyEvent e) {
    if (e is KeyUpEvent || _typing || !mounted) return false;
    final keys = HardwareKeyboard.instance;
    final command = keys.isControlPressed || keys.isMetaPressed;
    final key = e.logicalKey;
    final actions = TimelineActions(ref);
    final repeat = e is KeyRepeatEvent;

    if (command && key == LogicalKeyboardKey.keyZ && !repeat) {
      keys.isShiftPressed ? actions.redo() : actions.undo();
      return true;
    }
    if (command && key == LogicalKeyboardKey.keyY && !repeat) {
      actions.redo();
      return true;
    }
    if (command || keys.isAltPressed) return false;
    if (key == LogicalKeyboardKey.space && !repeat) {
      actions.playPause();
      return true;
    }
    if (ref.read(editorModeProvider) != EditorMode.motion) return false;
    if (key == LogicalKeyboardKey.keyS && !repeat) {
      actions.split();
      return true;
    }
    if ((key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) && !repeat) {
      actions.delete();
      return true;
    }
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.arrowRight) {
      final step = keys.isShiftPressed ? 1.0 : 1 / 30;
      final t = ref.read(playheadProvider) + (key == LogicalKeyboardKey.arrowLeft ? -step : step);
      actions.seek(t.clamp(0.0, actions.length > 0 ? actions.length : 0.0));
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
