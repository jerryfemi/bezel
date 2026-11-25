import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_icons.dart';
import '../../../app/theme/bezel_type.dart';
import '../../../core/widgets/pressable.dart';
import '../../motion/widgets/format_time.dart';
import '../../timeline/model/media_asset.dart';
import '../../timeline/state/timeline_actions.dart';
import '../../timeline/state/tracks_provider.dart';

/// One file in the Media or Audio panel. Click puts it on the timeline at
/// the playhead; drag drops it wherever you let go on the timeline.
class AssetTile extends ConsumerStatefulWidget {
  const AssetTile({super.key, required this.asset});

  final MediaAsset asset;

  @override
  ConsumerState<AssetTile> createState() => _AssetTileState();
}

class _AssetTileState extends ConsumerState<AssetTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final inUse = ref.watch(tracksProvider.select((t) =>
        [...t.screens, ...t.audio].any((c) => c.assetId == asset.id)));
    final kind = switch (asset.kind) {
      AssetKind.image => 'Image',
      AssetKind.video => formatClipTime(asset.duration ?? 0),
      AssetKind.audio => formatClipTime(asset.duration ?? 0),
    };
    final row = Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _hover ? BezelColors.hover : null,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(children: [
        _Thumb(asset: asset),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(asset.name,
                style: BezelType.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(inUse ? '$kind · on the timeline' : kind, style: BezelType.caption),
          ]),
        ),
      ]),
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Draggable<MediaAsset>(
        data: asset,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: _DragChip(asset: asset),
        childWhenDragging: Opacity(opacity: 0.4, child: row),
        child: Pressable(
          onTap: () => TimelineActions(ref).placeAsset(asset),
          label: 'Add ${asset.name} at the playhead',
          pressedScale: 0.98,
          child: row,
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.asset});

  final MediaAsset asset;

  @override
  Widget build(BuildContext context) {
    final isAudio = asset.kind == AssetKind.audio;
    final image = switch (asset.kind) {
      AssetKind.image => asset.url,
      AssetKind.video => asset.filmstrip.isEmpty ? null : asset.filmstrip.first,
      AssetKind.audio => null,
    };
    return Container(
      width: isAudio ? 36 : 24,
      height: isAudio ? 36 : 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isAudio ? const Color(0xFF173A24) : const Color(0xFF26262B),
        borderRadius: BorderRadius.circular(5),
      ),
      child: image != null
          ? Image.network(image, fit: BoxFit.cover)
          : Icon(isAudio ? BezelIcons.audio : BezelIcons.screenClip,
              size: 14, color: isAudio ? const Color(0xFF52C77E) : BezelColors.textTertiary),
    );
  }
}

/// What follows the pointer while dragging a file to the timeline.
class _DragChip extends StatelessWidget {
  const _DragChip({required this.asset});

  final MediaAsset asset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: BezelColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: BezelColors.accentLine),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Text(asset.name,
            style: BezelType.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
