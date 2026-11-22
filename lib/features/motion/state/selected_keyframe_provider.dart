import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The keyframe being edited in the inspector, by id.
final selectedKeyframeProvider = StateProvider<String?>((ref) => null);
