import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/frame_shape.dart';
import '../../editor/state/project_title_provider.dart';
import '../../editor/state/scene_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../timeline/state/assets_provider.dart';
import '../../timeline/state/tracks_provider.dart';
import '../export_settings.dart';

enum ExportStatus { idle, rendering, done, failed }

class ExportState {
  const ExportState({
    this.settings = const ExportSettings(),
    this.status = ExportStatus.idle,
    this.frame = 0,
    this.total = 0,
    this.message,
  });

  final ExportSettings settings;
  final ExportStatus status;
  final int frame;
  final int total;

  /// File name when done, or what went wrong.
  final String? message;

  double get progress => total == 0 ? 0 : frame / total;

  ExportState copyWith({
    ExportSettings? settings, ExportStatus? status, int? frame, int? total, String? message,
  }) => ExportState(
        settings: settings ?? this.settings,
        status: status ?? this.status,
        frame: frame ?? this.frame,
        total: total ?? this.total,
        message: message,
      );
}

class ExportNotifier extends Notifier<ExportState> {
  /// The last video format the user picked, so we can go back to it.
  ExportFormat _videoFormat = ExportFormat.mp4;

  @override
  ExportState build() {
    // Each time the sheet opens, start on the format that fits the project:
    // a still image when nothing moves, a video when something does.
    ref.listen(exportSheetOpenProvider, (was, open) {
      if (open && was != true && state.status != ExportStatus.rendering) _suggestFormat();
    });
    // First build happens as the sheet opens, so pick the format here too.
    return ExportState(
        settings: ExportSettings(format: _moves() ? ExportFormat.mp4 : ExportFormat.png));
  }

  /// Anything that changes over time: motion, a screen recording, sound, or
  /// more than one caption or screen clip.
  bool _moves() {
    final tracks = ref.read(tracksProvider);
    final assets = ref.read(assetsProvider);
    return !ref.read(timelineProvider).isEmpty ||
        tracks.audio.isNotEmpty ||
        tracks.captions.length > 1 ||
        tracks.screens.length > 1 ||
        tracks.screens.any((c) => assets[c.assetId]?.isVideo ?? false);
  }

  void _suggestFormat() {
    final moves = _moves();
    final current = state.settings.format;
    final isVideo = current != ExportFormat.png;
    if (moves && !isVideo) {
      state = ExportState(settings: state.settings.copyWith(format: _videoFormat));
    } else if (!moves && isVideo) {
      state = ExportState(settings: state.settings.copyWith(format: ExportFormat.png));
    }
  }

  void update(ExportSettings settings) {
    if (settings.format != ExportFormat.png) _videoFormat = settings.format;
    state = ExportState(settings: settings);
  }

  Future<void> start() async {
    final scene = ref.read(sceneControllerProvider);
    if (scene == null || state.status == ExportStatus.rendering) return;
    final shape = ref.read(frameShapeProvider);
    final name = _fileName(ref.read(projectTitleProvider));
    state = state.copyWith(status: ExportStatus.rendering, frame: 0, total: 0);
    try {
      final file = await scene.exportClip(
        state.settings.toJson(shape, name),
        (frame, total) => state = state.copyWith(frame: frame, total: total),
      );
      state = file == null
          ? ExportState(settings: state.settings)
          : state.copyWith(status: ExportStatus.done, message: file);
    } catch (e) {
      state = state.copyWith(status: ExportStatus.failed, message: '$e');
    }
  }

  void cancel() => ref.read(sceneControllerProvider)?.cancelExport();

  /// Back to the settings after a finished or failed export.
  void reset() => state = ExportState(settings: state.settings);

  static String _fileName(String title) {
    final cleaned = title.trim().replaceAll(RegExp(r'[^\w\- ]+'), '').replaceAll(' ', '-');
    return cleaned.isEmpty ? 'bezel-clip' : cleaned.toLowerCase();
  }
}

final exportProvider = NotifierProvider<ExportNotifier, ExportState>(ExportNotifier.new);

/// Whether the export sheet is open above the dock.
final exportSheetOpenProvider = StateProvider<bool>((ref) => false);
