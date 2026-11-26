import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which screen is in front: the projects grid or the editor.
enum AppScreen { home, editor }

final appScreenProvider = StateProvider<AppScreen>((ref) => AppScreen.home);
