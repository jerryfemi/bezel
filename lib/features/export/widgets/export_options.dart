import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/segmented_control.dart';
import '../../editor/state/frame_shape.dart';
import '../../motion/state/timeline_provider.dart';
import '../../scene3d/scene_specs.dart';
import '../../tools/background/background_provider.dart';
import '../../timeline/model/tracks.dart';
import '../../timeline/state/tracks_provider.dart';
import '../export_settings.dart';
import '../state/export_provider.dart';
import 'export_estimate.dart';

/// Format, shape, quality and frame rate.
class ExportOptions extends ConsumerWidget {
  const ExportOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(exportProvider).settings;
    final shape = ref.watch(frameShapeProvider);
    final notifier = ref.read(exportProvider.notifier);
    final length = clipLength(ref.watch(tracksProvider), ref.watch(timelineProvider).duration);
    final seconds = length > 0 ? length : stillSeconds;
    final transparent =
        ref.watch(backgroundProvider.select((b) => b.style == BackgroundStyle.transparent));

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PanelSection(
        title: 'Format',
        trailing: Text(settings.format.hint,
            style: BezelType.caption.copyWith(color: BezelColors.textSecondary)),
        child: SegmentedControl<ExportFormat>(
          options: ExportFormat.values, selected: settings.format,
          labelOf: (f) => f.label, onChanged: (f) => notifier.update(settings.copyWith(format: f)),
        ),
      ),
      if (transparent) ...[
        const SizedBox(height: 8),
        Text(
          settings.format.keepsTransparency
              ? 'The background stays see-through in this PNG.'
              : 'Videos can\'t be see-through yet, so they get the background colour.',
          style: BezelType.caption.copyWith(color: BezelColors.textSecondary),
        ),
      ],
      const SizedBox(height: 16),
      PanelSection(
        title: 'Shape',
        trailing: Text(shape.usedFor,
            style: BezelType.caption.copyWith(color: BezelColors.textSecondary)),
        child: SegmentedControl<FrameShape>(
          options: FrameShape.values, selected: shape, labelOf: (s) => s.label,
          onChanged: (s) => ref.read(frameShapeProvider.notifier).state = s,
        ),
      ),
      if (settings.format != ExportFormat.gif) ...[
        const SizedBox(height: 16),
        PanelSection(
          title: 'Quality',
          child: SegmentedControl<ExportQuality>(
            options: ExportQuality.values, selected: settings.quality, labelOf: (q) => q.label,
            onChanged: (q) => notifier.update(settings.copyWith(quality: q)),
          ),
        ),
      ],
      if (settings.format.isVideo) ...[
        const SizedBox(height: 16),
        PanelSection(
          title: 'Frame rate',
          child: SegmentedControl<int>(
            options: const [30, 60], selected: settings.fps, labelOf: (f) => '$f fps',
            onChanged: (f) => notifier.update(settings.copyWith(fps: f)),
          ),
        ),
      ],
      const SizedBox(height: 16),
      ExportEstimate(settings: settings, shape: shape, seconds: seconds, hasMotion: length > 0),
    ]);
  }
}
