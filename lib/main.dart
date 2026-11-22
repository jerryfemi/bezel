import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/editor_screen.dart';
import 'features/scene3d/spike/scene_spike_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bezel',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      // `?scene=3d` opens the phase 2 3D test bench; the editor is unchanged.
      home: Uri.base.queryParameters['scene'] == '3d'
          ? const SceneSpikePage()
          : const EditorScreen(),
    );
  }
}

// motion timing, animation, timeline tush background(screen), color for phones, expand slider position, radial drag
