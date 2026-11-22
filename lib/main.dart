import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme/bezel_theme.dart';
import 'features/editor/editor_page.dart';
import 'features/projects/data/project_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProjectStore.init();
  runApp(const ProviderScope(child: BezelApp()));
}

class BezelApp extends StatelessWidget {
  const BezelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bezel',
      debugShowCheckedModeBanner: false,
      theme: buildBezelTheme(),
      home: const EditorPage(),
    );
  }
}
