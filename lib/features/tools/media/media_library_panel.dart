import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_type.dart';
import '../../timeline/model/media_asset.dart';
import '../../timeline/state/assets_provider.dart';
import '../../timeline/state/timeline_actions.dart';
import 'add_file_button.dart';
import 'asset_tile.dart';

/// The Media panel: every screenshot and recording in the project.
class MediaLibraryPanel extends ConsumerStatefulWidget {
  const MediaLibraryPanel({super.key});

  @override
  ConsumerState<MediaLibraryPanel> createState() => _MediaLibraryPanelState();
}

class _MediaLibraryPanelState extends ConsumerState<MediaLibraryPanel> {
  bool _busy = false;

  Future<void> _add() async {
    setState(() => _busy = true);
    try {
      await TimelineActions(ref).importMedia();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = ref
        .watch(assetsProvider)
        .values
        .where((a) => a.kind != AssetKind.audio)
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AddFileButton(label: 'Add screenshot or recording', onTap: _add, busy: _busy),
      const SizedBox(height: 10),
      for (final asset in files.reversed) AssetTile(key: ValueKey(asset.id), asset: asset),
      const SizedBox(height: 10),
      Text(
        files.isEmpty
            ? 'Your files show up here. The first one goes straight onto the phone.'
            : 'Click a file to put it on the screen at the playhead, or drag it onto the timeline.',
        style: BezelType.caption.copyWith(height: 1.45),
      ),
    ]);
  }
}
