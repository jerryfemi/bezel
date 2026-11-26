import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../editor/editor_page.dart';
import 'app_screen.dart';
import 'home_page.dart';

/// Home sits over the editor rather than replacing it, so the 3D view stays
/// loaded and opening a project is instant. The editor takes no keys or
/// clicks while Home is in front.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(appScreenProvider) == AppScreen.home;
    return Stack(children: [
      Positioned.fill(
        child: ExcludeFocus(
          excluding: home,
          child: IgnorePointer(ignoring: home, child: const EditorPage()),
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          ignoring: !home,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            opacity: home ? 1 : 0,
            child: const HomePage(),
          ),
        ),
      ),
    ]);
  }
}
