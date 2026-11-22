import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/panel_section.dart';
import '../../../core/widgets/swatch_button.dart';
import '../../scene3d/device_catalog.dart';
import 'device_selection.dart';
import 'device_tile.dart';

class DevicePanel extends ConsumerWidget {
  const DevicePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(deviceSelectionProvider);
    final notifier = ref.read(deviceSelectionProvider.notifier);
    final finishes = selection.profile?.finishes ?? const [];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 156,
        ),
        children: [
          for (final entry in deviceCatalog)
            DeviceTile(
              label: entry.label,
              meta: selection.loading && entry.id == selection.entry.id ? 'Loading…' : '3D · 1 screen',
              bodyColor: entry.id == selection.entry.id
                  ? selection.finish?.body ?? const Color(0xFF3C3C3D)
                  : const Color(0xFF3C3C3D),
              selected: entry.id == selection.entry.id,
              onTap: () => notifier.select(entry),
            ),
        ],
      ),
      if (selection.error != null) ...[
        const SizedBox(height: 10),
        Text(selection.error!, style: BezelType.label.copyWith(color: BezelColors.danger)),
      ],
      const SizedBox(height: 18),
      PanelSection(
        title: 'Finish',
        trailing: Text(selection.finish?.name ?? '', style: BezelType.label),
        child: Wrap(children: [
          for (final f in finishes)
            SwatchButton(
              color: f.body,
              label: f.name,
              selected: f.id == selection.finishId,
              onTap: () => notifier.setFinish(f.id),
            ),
        ]),
      ),
    ]);
  }
}
