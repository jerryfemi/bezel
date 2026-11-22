import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/timeline_provider.dart';
import '../state/timeline_zoom_provider.dart';
import 'timeline_track.dart';

/// Shows the track at the current zoom. At 100% the whole clip fits; zoomed
/// in, it scrolls sideways. Trackpad pinch or Ctrl+scroll zooms; plain
/// scroll pans.
class TimelineViewport extends ConsumerStatefulWidget {
  const TimelineViewport({super.key});

  @override
  ConsumerState<TimelineViewport> createState() => _TimelineViewportState();
}

class _TimelineViewportState extends ConsumerState<TimelineViewport> {
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
    final duration = ref.watch(timelineProvider).duration;
    final zoom = ref.watch(timelineZoomProvider);
    final span = math.max(duration + 1, 5.0);

    return Listener(
      onPointerSignal: _onSignal,
      child: LayoutBuilder(builder: (context, box) {
        const pad = 8.0;
        final width = (box.maxWidth - pad * 2) * zoom;
        return Scrollbar(
          controller: _scroll,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: pad),
            child: SizedBox(
              width: width,
              height: box.maxHeight,
              child: TimelineTrack(pixelsPerSecond: width / span, span: span),
            ),
          ),
        );
      }),
    );
  }
}
