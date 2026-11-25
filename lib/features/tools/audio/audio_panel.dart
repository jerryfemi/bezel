import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_type.dart';
import '../../timeline/model/media_asset.dart';
import '../../timeline/state/assets_provider.dart';
import '../../timeline/state/timeline_actions.dart';
import '../media/add_file_button.dart';
import '../media/asset_tile.dart';

/// The Audio panel: music and voice-overs in the project.
class AudioPanel extends ConsumerStatefulWidget {
  const AudioPanel({super.key});

  @override
  ConsumerState<AudioPanel> createState() => _AudioPanelState();
}

class _AudioPanelState extends ConsumerState<AudioPanel> {
  bool _busy = false;

  Future<void> _add() async {
    setState(() => _busy = true);
    try {
      await TimelineActions(ref).addAudio();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = ref
        .watch(assetsProvider)
        .values
        .where((a) => a.kind == AssetKind.audio)
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AddFileButton(label: 'Add music or voice-over', onTap: _add, busy: _busy),
      const SizedBox(height: 10),
      for (final asset in files.reversed) AssetTile(key: ValueKey(asset.id), asset: asset),
      const SizedBox(height: 10),
      Text(
        'New sound starts at the playhead. Music longer than the video is trimmed to fit.',
        style: BezelType.caption.copyWith(height: 1.45),
      ),
    ]);
  }
}
