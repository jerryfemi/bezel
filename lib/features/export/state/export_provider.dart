import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/frame_shape.dart';
import '../../editor/state/project_title_provider.dart';
import '../../editor/state/scene_provider.dart';
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
  @override
  ExportState build() => const ExportState();

  void update(ExportSettings settings) =>
      state = ExportState(settings: settings);

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
