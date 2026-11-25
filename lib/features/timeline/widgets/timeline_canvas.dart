import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/bezel_colors.dart';
import '../../../app/theme/bezel_type.dart';
import '../../editor/state/active_tool_provider.dart';
import '../../editor/state/editor_tool.dart';
import '../../editor/state/scene_provider.dart';
import '../../motion/state/selected_keyframe_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../motion/state/timeline_zoom_provider.dart';
import '../../tools/text/caption_provider.dart';
import '../model/clips.dart';
import '../model/media_asset.dart';
import '../model/tracks.dart';
import '../state/assets_provider.dart';
import '../state/timeline_actions.dart';
import '../state/tracks_provider.dart';
import 'clip_faces.dart';
import 'clip_row.dart';
import 'motion_row.dart';
import 'ruler_painter.dart';
import 'track_style.dart';

/// The scrolling part of the timeline: ruler, the four tracks, the end of
/// the video and the playhead. Ctrl+scroll or pinch zooms; scroll pans.
class TimelineCanvas extends ConsumerStatefulWidget {
  const TimelineCanvas({super.key});

  @override
  ConsumerState<TimelineCanvas> createState() => _TimelineCanvasState();
}

class _TimelineCanvasState extends ConsumerState<TimelineCanvas> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onSignal(PointerSignalEvent e) {
    final zoom = ref.read(timelineZoomProvider.notifier);
    if (e is PointerScaleEvent) {
      zoom.scaleBy(e.scale);
    } else if (e is PointerScrollEvent) {
      if (HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed) {
        zoom.scaleBy(math.exp(-e.scrollDelta.dy * 0.002));
      } else if (_scroll.hasClients) {
        final delta = e.scrollDelta.dx != 0 ? e.scrollDelta.dx : e.scrollDelta.dy;
        _scroll.jumpTo((_scroll.offset + delta).clamp(0, _scroll.position.maxScrollExtent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = ref.watch(tracksProvider);
    final motionEnd = ref.watch(timelineProvider).duration;
    final length = clipLength(tracks, motionEnd);
    final zoom = ref.watch(timelineZoomProvider);
    final span = math.max(length + 3, 10.0);

    return Listener(
      onPointerSignal: _onSignal,
      child: LayoutBuilder(builder: (context, box) {
        final width = box.maxWidth * zoom;
        final pps = width / span;
        return Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: width,
              height: box.maxHeight,
              child: _Tracks(pps: pps, length: length, isEmpty: tracks.isEmpty && motionEnd == 0),
            ),
          ),
        );
      }),
    );
  }
}

class _Tracks extends ConsumerWidget {
  const _Tracks({required this.pps, required this.length, required this.isEmpty});

  final double pps;
  final double length;
  final bool isEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scene = ref.watch(sceneControllerProvider);
    final assets = ref.watch(assetsProvider);
    final actions = TimelineActions(ref);
    const top = TrackStyle.rulerHeight;

    void scrub(double x) => actions.seek(x / pps);

    double rowTop(TrackKind k) => top + TrackStyle.topOf(k);

    // Files dragged from the Media or Audio panel land where they're dropped.
    return DragTarget<MediaAsset>(
      onAcceptWithDetails: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final x = box.globalToLocal(details.offset).dx;
        actions.placeAsset(details.data, at: x / pps);
      },
      builder: (context, candidates, _) {
        final dragged = candidates.isEmpty ? null : candidates.first;
        final lane = dragged == null
            ? null
            : dragged.kind == AssetKind.audio ? TrackKind.audio : TrackKind.screen;
        return Stack(clipBehavior: Clip.none, children: [
      // Lanes; clicking empty space clears the selection.
      for (final k in TrackStyle.order)
        Positioned(
          left: 0, right: 0, top: rowTop(k), height: TrackStyle.of(k).height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              actions.select(null);
              ref.read(selectedKeyframeProvider.notifier).state = null;
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _EmptyHint(kind: k),
            ),
          ),
        ),
      Positioned(
        left: 0, right: 0, top: 0, height: top,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => scrub(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => scrub(d.localPosition.dx),
          child: CustomPaint(painter: RulerPainter(pixelsPerSecond: pps, length: length)),
        ),
      ),
      Positioned(
        left: 0, right: 0, top: rowTop(TrackKind.caption), height: TrackStyle.of(TrackKind.caption).height,
        child: ClipRow(
          kind: TrackKind.caption,
          pixelsPerSecond: pps,
          faceFor: (c) => CaptionFace(clip: c as CaptionClip),
          onDoubleTap: (c) {
            // Open the Text panel on this caption, at its first frame.
            actions.seek(c.start);
            ref.read(activeToolProvider.notifier).open(EditorTool.text);
            ref.read(captionEditingProvider.notifier).state = null;
          },
        ),
      ),
      Positioned(
        left: 0, right: 0, top: rowTop(TrackKind.screen), height: TrackStyle.of(TrackKind.screen).height,
        child: ClipRow(
          kind: TrackKind.screen,
          pixelsPerSecond: pps,
          faceFor: (c) => FilmstripFace(
              clip: c as MediaClip, asset: assets[c.assetId], pixelsPerSecond: pps),
        ),
      ),
      Positioned(
        left: 0, right: 0, top: rowTop(TrackKind.motion), height: TrackStyle.of(TrackKind.motion).height,
        child: MotionRow(pixelsPerSecond: pps, height: TrackStyle.of(TrackKind.motion).height),
      ),
      Positioned(
        left: 0, right: 0, top: rowTop(TrackKind.audio), height: TrackStyle.of(TrackKind.audio).height,
        child: ClipRow(
          kind: TrackKind.audio,
          pixelsPerSecond: pps,
          faceFor: (c) => WaveformFace(
              clip: c as MediaClip, asset: assets[c.assetId], color: TrackStyle.of(TrackKind.audio).edge),
        ),
      ),
      if (length > 0)
        Positioned.fill(
          top: top,
          child: IgnorePointer(child: CustomPaint(painter: EndMarkerPainter(length * pps))),
        ),
      if (scene != null)
        Positioned.fill(
          child: IgnorePointer(
            child: ValueListenableBuilder<double>(
              valueListenable: scene.time,
              builder: (_, t, __) => CustomPaint(painter: PlayheadPainter(t * pps, rulerHeight: top)),
            ),
          ),
        ),
      if (lane != null)
        Positioned(
          left: 0, right: 0, top: rowTop(lane), height: TrackStyle.of(lane).height,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: TrackStyle.of(lane).edge.withValues(alpha: 0.12),
                border: Border.all(color: TrackStyle.of(lane).edge, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        ]);
      },
    );
  }
}

/// A quiet hint in an empty track saying how to fill it.
class _EmptyHint extends ConsumerWidget {
  const _EmptyHint({required this.kind});

  final TrackKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final empty = switch (kind) {
      TrackKind.motion => ref.watch(timelineProvider).keyframes.isEmpty,
      _ => ref.watch(tracksProvider.select((t) => t.on(kind).isEmpty)),
    };
    if (!empty) return const SizedBox.shrink();
    final text = switch (kind) {
      TrackKind.caption => 'Add a caption with + — one block per line of text',
      TrackKind.screen => 'Add a screenshot or screen recording with +',
      TrackKind.motion => 'Pick a motion preset on the left, or add keyframes with +',
      TrackKind.audio => 'Add music or a voice-over with +',
    };
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: BezelType.caption.copyWith(color: BezelColors.textTertiary)),
      ),
    );
  }
}
