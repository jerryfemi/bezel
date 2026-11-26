import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/bezel_type.dart';
import '../../../../core/widgets/chip_button.dart';
import '../../../motion/widgets/format_time.dart';
import '../../../tools/media/screen_media_provider.dart';
import '../../model/clips.dart';
import '../../model/media_asset.dart';
import '../../state/timeline_actions.dart';

/// What a screen clip shows: the file, which part of it plays, and the
/// buttons to swap the file or remove the clip.
class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({super.key, required this.clip, required this.asset});

  final MediaClip clip;
  final MediaAsset? asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = asset;
    final plays = file?.duration == null
        ? 'An image. Drag its edges on the timeline to set how long it shows.'
        : 'Plays ${formatClipTime(clip.inPoint)} – ${formatClipTime(clip.inPoint + clip.length)} '
            'of the ${formatClipTime(file!.duration!)} recording. Drag the clip\'s edges to trim it.';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(file?.name ?? 'Missing file',
          style: BezelType.label.copyWith(fontWeight: FontWeight.w600),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 6),
      Text(plays, style: BezelType.caption.copyWith(height: 1.45)),
      const SizedBox(height: 16),
      ClipActions(onReplace: () => ref.read(screenMediaProvider.notifier).pick()),
    ]);
  }
}

/// Replace (when given) and Delete, in plain colours.
class ClipActions extends ConsumerWidget {
  const ClipActions({super.key, this.onReplace, this.deleteLabel = 'Delete clip'});

  final VoidCallback? onReplace;
  final String deleteLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      if (onReplace != null)
        ChipButton(icon: Icons.swap_horiz, label: 'Replace file', onTap: onReplace),
      ChipButton(
        icon: Icons.delete_outline,
        label: deleteLabel,
        onTap: () => TimelineActions(ref).delete(),
      ),
    ]);
  }
}
