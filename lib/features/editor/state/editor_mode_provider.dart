import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Design: set up the shot. Motion: animate it over time.
enum EditorMode { design, motion }

final editorModeProvider = StateProvider<EditorMode>((ref) => EditorMode.design);
