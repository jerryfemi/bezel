import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_metrics.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/floating_surface.dart';
import '../state/timeline_provider.dart';
import 'timeline_viewport.dart';
import 'transport_bar.dart';

/// The docked timeline at the bottom of Motion mode.
class TimelinePanel extends ConsumerWidget {
  const TimelinePanel({super.key});

  static const height = 158.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empty = ref.watch(timelineProvider).keyframes.isEmpty;
    return FloatingSurface(
      radius: BezelRadius.panel,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        height: height - 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const TransportBar(),
          const SizedBox(height: 8),
          Expanded(
            child: empty
                ? Center(
                    child: Text(
                      'No motion yet. Pick a preset on the left, or add keyframes as you pose the phone.',
                      style: BezelType.label.copyWith(color: BezelColors.textSecondary),
                    ),
                  )
                : const TimelineViewport(),
          ),
        ]),
      ),
    );
  }
}
