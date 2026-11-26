import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../projects/state/projects_provider.dart';
import 'app_screen.dart';

/// Moving between Home and the editor, keeping the project saved.
class Navigate {
  const Navigate(this.ref);

  final WidgetRef ref;

  Future<void> open(String id) async {
    if (ref.read(projectsProvider).currentId != id) {
      await ref.read(projectsProvider.notifier).open(id);
    }
    ref.read(appScreenProvider.notifier).state = AppScreen.editor;
  }

  Future<void> newProject() async {
    await ref.read(projectsProvider.notifier).newProject();
    ref.read(appScreenProvider.notifier).state = AppScreen.editor;
  }

  Future<void> home() async {
    ref.read(appScreenProvider.notifier).state = AppScreen.home;
    await ref.read(projectsProvider.notifier).saveNow();
  }
}
