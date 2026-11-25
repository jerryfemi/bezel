import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/clips.dart';

/// The playback position in seconds, mirrored from the 3D view's clock so
/// providers can depend on it (see scene_bootstrap.dart).
final playheadProvider = StateProvider<double>((ref) => 0);

/// The clip selected on the timeline (click a block), if any.
final selectedClipProvider = StateProvider<ClipRef?>((ref) => null);
