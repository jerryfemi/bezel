import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../../../core/widgets/pressable.dart';
import '../model/motion_presets.dart';
import '../state/timeline_provider.dart';

/// Left panel in Motion mode: ready-made moves, added to the end of the clip.
class PresetListPanel extends ConsumerWidget {
  const PresetListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    final notifier = ref.read(timelineProvider.notifier);
    return FloatingSurface(
      radius: BezelRadius.panel,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('Presets', style: BezelType.title),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
          child: Text('Click one to add it to the end of the clip.',
              style: BezelType.caption.copyWith(color: BezelColors.textSecondary)),
        ),
        Expanded(
          child: ListView(padding: EdgeInsets.zero, children: [
            for (final preset in motionPresets)
              _PresetRow(preset: preset, onTap: () => notifier.addPreset(preset)),
          ]),
        ),
        if (!timeline.isEmpty)
          TextButton.icon(
            onPressed: notifier.clear,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Clear motion'),
            style: TextButton.styleFrom(foregroundColor: BezelColors.textSecondary),
          ),
      ]),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.preset, required this.onTap});

  final MotionPreset preset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      label: 'Add ${preset.name}',
      pressedScale: 0.98,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(BezelRadius.control)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(preset.name, style: BezelType.label.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(preset.description, style: BezelType.caption),
            ]),
          ),
          const Icon(Icons.add, size: 16, color: BezelColors.textSecondary),
        ]),
      ),
    );
  }
}
