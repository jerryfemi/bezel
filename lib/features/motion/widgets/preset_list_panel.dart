import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/chip_button.dart';
import '../../../core/widgets/pressable.dart';
import '../model/motion_presets.dart';
import '../state/timeline_provider.dart';

/// The Motion panel: ready-made moves, added to the end of the motion track.
class PresetListPanel extends ConsumerWidget {
  const PresetListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    final notifier = ref.read(timelineProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Click a move to add it to the end of the motion track.',
          style: BezelType.caption.copyWith(height: 1.4)),
      const SizedBox(height: 10),
      for (final preset in motionPresets)
        _PresetRow(preset: preset, onTap: () => notifier.addPreset(preset)),
      if (!timeline.isEmpty) ...[
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: ChipButton(icon: Icons.close, label: 'Clear motion', onTap: notifier.clear),
        ),
      ],
    ]);
  }
}

class _PresetRow extends StatefulWidget {
  const _PresetRow({required this.preset, required this.onTap});

  final MotionPreset preset;
  final VoidCallback onTap;

  @override
  State<_PresetRow> createState() => _PresetRowState();
}

class _PresetRowState extends State<_PresetRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Pressable(
        onTap: widget.onTap,
        label: 'Add ${widget.preset.name}',
        pressedScale: 0.98,
        child: Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: _hover ? BezelColors.hover : null,
            borderRadius: BorderRadius.circular(BezelRadius.control),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.preset.name,
                    style: BezelType.label.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(widget.preset.description, style: BezelType.caption),
              ]),
            ),
            const Icon(Icons.add, size: 16, color: BezelColors.textSecondary),
          ]),
        ),
      ),
    );
  }
}
