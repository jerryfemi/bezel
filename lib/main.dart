import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/theme/bezel_metrics.dart';
import 'app/theme/bezel_theme.dart';
import 'core/widgets/ui_scale.dart';
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
      // Drawn a little smaller than 1:1, like 80% browser zoom, so the
      // editor feels compact on an ordinary laptop screen.
      builder: (context, child) => UiScale(scale: BezelSpace.uiScale, child: child!),
      home: const EditorPage(),
    );
  }
}
