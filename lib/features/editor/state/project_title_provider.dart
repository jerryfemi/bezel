import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The name shown in the top bar, saved with the project.
final projectTitleProvider = StateProvider<String>((ref) => 'Untitled clip');
