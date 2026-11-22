import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme/bezel_theme.dart';
import 'features/editor/editor_page.dart';
import 'screens/editor_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: BezelApp()));
}

class BezelApp extends StatelessWidget {
  const BezelApp({super.key});

  /// `?legacy=1` opens the old editor until its files are removed.
  static final _legacy = Uri.base.queryParameters['legacy'] == '1';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bezel',
      debugShowCheckedModeBanner: false,
      theme: _legacy ? AppTheme.darkTheme : buildBezelTheme(),
      home: _legacy ? const EditorScreen() : const EditorPage(),
    );
  }
}
