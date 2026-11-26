import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../editor/state/scene_provider.dart';
import '../../motion/state/timeline_provider.dart';
import '../../scene3d/scene_specs.dart';
import '../model/clip_ops.dart' as ops;
import '../model/clips.dart';
import '../model/media_asset.dart';
import '../model/tracks.dart';
import 'assets_provider.dart';
import 'edit_history.dart';
import 'playhead_provider.dart';

/// How long a new caption or image clip lasts by default, in seconds.
const defaultClipSeconds = 3.0;

/// The caption, screen and audio clips. Every change is recorded for undo and
/// sent to the 3D view.
class TracksNotifier extends Notifier<Tracks> {
  int _count = 0;

  @override
  Tracks build() => const Tracks();

  String _id(String prefix) => '$prefix${DateTime.now().microsecondsSinceEpoch}${_count++}';

  /// The finished video's length right now (0 for a still).
  double get length => clipLength(state, ref.read(timelineProvider).duration);

  // ---- Adding -------------------------------------------------------------

  /// Adds a caption at [at] (default: the playhead) in the first free space.
  /// The very first caption spans the whole clip.
  CaptionClip addCaption(CaptionSpec spec, {double? at}) {
    final double start;
    final double length;
    if (state.captions.isEmpty) {
      start = 0;
      length = this.length > 0 ? this.length : defaultClipSeconds;
    } else {
      length = defaultClipSeconds;
      start = ops.firstFreeStart(state.captions, at ?? ref.read(playheadProvider), length);
    }
    final clip = CaptionClip(id: _id('c'), start: start, end: start + length, spec: spec);
    _set(state.copyWith(captions: [...state.captions, clip]));
    return clip;
  }

  /// Puts [asset] on the screen track at the playhead (or after what is there).
  MediaClip addScreen(MediaAsset asset, {double? at}) {
    final length = asset.duration ?? (state.screens.isEmpty && this.length > 0 ? this.length : defaultClipSeconds);
    final start = ops.firstFreeStart(state.screens, at ?? ref.read(playheadProvider), length);
    final clip = MediaClip(id: _id('s'), start: start, end: start + length, assetId: asset.id);
    _set(state.copyWith(screens: [...state.screens, clip]));
    return clip;
  }

  /// Puts a sound file on the audio track. Music longer than the clip is
  /// trimmed to fit it.
  MediaClip addAudio(MediaAsset asset, {double? at}) {
    final start = ops.firstFreeStart(state.audio, at ?? ref.read(playheadProvider), 0.5);
    var length = asset.duration ?? defaultClipSeconds;
    if (this.length > start + ops.minClipLength) length = math.min(length, this.length - start);
    for (final c in state.audio) {
      if (c.start >= start) {
        length = math.min(length, c.start - start); // stop before the next sound
        break;
      }
    }
    final clip = MediaClip(id: _id('m'), start: start, end: start + length, assetId: asset.id);
    _set(state.copyWith(audio: [...state.audio, clip]));
    return clip;
  }

  /// Swaps the file a screen clip shows, keeping its place on the timeline.
  void replaceScreenAsset(String clipId, MediaAsset asset) {
    _set(state.copyWith(screens: [
      for (final c in state.screens)
        if (c.id != clipId)
          c
        else
          c.copyWith(
            assetId: asset.id,
            inPoint: 0,
            end: asset.duration == null ? c.end : math.min(c.end, c.start + asset.duration!),
          ),
    ]));
  }

  // ---- Editing ------------------------------------------------------------

  void updateCaption(String id, CaptionSpec Function(CaptionSpec spec) change) {
    _set(state.copyWith(captions: [
      for (final c in state.captions) c.id == id ? c.copyWith(spec: change(c.spec)) : c,
    ]));
  }

  void setVolume(ClipRef clip, double volume) => _mapMedia(
      clip, (c) => c.copyWith(volume: volume.clamp(0.0, 1.0), muted: volume <= 0 ? c.muted : false));

  void toggleTrackMute(TrackKind kind) {
    final next = {...state.mutedTracks};
    if (!next.remove(kind)) next.add(kind);
    _set(state.copyWith(mutedTracks: next));
  }

  void toggleTrackLock(TrackKind kind) {
    final next = {...state.lockedTracks};
    if (!next.remove(kind)) next.add(kind);
    _set(state.copyWith(lockedTracks: next));
  }

  void setMuted(ClipRef clip, bool muted) => _mapMedia(clip, (c) => c.copyWith(muted: muted));

  /// Fades can't overlap: together they never run longer than the clip.
  void setFades(ClipRef clip, {double? fadeIn, double? fadeOut}) => _mapMedia(clip, (c) {
        final nextIn = (fadeIn ?? c.fadeIn).clamp(0.0, c.length);
        final nextOut = (fadeOut ?? c.fadeOut).clamp(0.0, c.length - nextIn);
        return c.copyWith(fadeIn: nextIn, fadeOut: nextOut);
      });

  /// Drags a clip so it starts at [start] (it stays between its neighbours).
  void move(ClipRef clip, double start) {
    final current = state.find(clip);
    if (current == null) return;
    final next = ops.clampStart(state.on(clip.track), current, start);
    final shift = next - current.start;
    if (shift == 0) return;
    if (clip.track == TrackKind.caption) {
      _mapCaption(clip.id, (c) => c.copyWith(start: c.start + shift, end: c.end + shift));
    } else {
      _mapMedia(clip, (c) => c.copyWith(start: c.start + shift, end: c.end + shift));
    }
  }

  /// Drags the left edge of a clip to [start].
  void trimStart(ClipRef clip, double start) {
    final current = state.find(clip);
    if (current == null) return;
    if (current is CaptionClip) {
      final r = ops.trimStart(state.captions, current, start);
      _mapCaption(clip.id, (c) => c.copyWith(start: r.start));
    } else if (current is MediaClip) {
      final source = _sourceLength(current);
      final r = ops.trimStart(state.on(clip.track), current, start, inPoint: current.inPoint, sourceLength: source);
      _mapMedia(clip, (c) => c.copyWith(start: r.start, inPoint: r.inPoint));
    }
  }

  /// Drags the right edge of a clip to [end].
  void trimEnd(ClipRef clip, double end) {
    final current = state.find(clip);
    if (current == null) return;
    if (current is CaptionClip) {
      final e = ops.trimEnd(state.captions, current, end);
      _mapCaption(clip.id, (c) => c.copyWith(end: e));
    } else if (current is MediaClip) {
      final e = ops.trimEnd(state.on(clip.track), current, end,
          inPoint: current.inPoint, sourceLength: _sourceLength(current));
      _mapMedia(clip, (c) => c.copyWith(end: e));
    }
  }

  /// Cuts a clip in two at [t]. Returns the right-hand half, or null.
  ClipRef? split(ClipRef clip, double t) {
    final current = state.find(clip);
    if (current == null || !ops.canSplit(current, t)) return null;
    ref.read(editHistoryProvider.notifier).breakStep();
    if (current is CaptionClip) {
      final right = current.copyWith(id: _id('c'), start: t);
      _set(state.copyWith(captions: [
        for (final c in state.captions) c.id == current.id ? c.copyWith(end: t) : c,
        right,
      ]));
      return ClipRef(TrackKind.caption, right.id);
    }
    final media = current as MediaClip;
    // The fade-in stays on the left half, the fade-out on the right.
    final right = media.copyWith(
        id: _id('s'), start: t, inPoint: media.inPoint + (t - media.start), fadeIn: 0);
    final list = [
      for (final c in state.on(clip.track).cast<MediaClip>())
        c.id == media.id ? c.copyWith(end: t, fadeOut: 0) : c,
      right,
    ];
    _set(clip.track == TrackKind.screen ? state.copyWith(screens: list) : state.copyWith(audio: list));
    return ClipRef(clip.track, right.id);
  }

  void delete(ClipRef clip) {
    ref.read(editHistoryProvider.notifier).breakStep();
    _set(switch (clip.track) {
      TrackKind.caption => state.copyWith(captions: state.captions.where((c) => c.id != clip.id).toList()),
      TrackKind.screen => state.copyWith(screens: state.screens.where((c) => c.id != clip.id).toList()),
      TrackKind.audio => state.copyWith(audio: state.audio.where((c) => c.id != clip.id).toList()),
      TrackKind.motion => state,
    });
  }

  // ---- Whole-state --------------------------------------------------------

  /// Opening a project: replaces everything without an undo step.
  void load(Tracks tracks) {
    state = tracks;
    push();
  }

  /// Undo/redo.
  void restore(Tracks tracks) {
    state = tracks;
    push();
  }

  /// Sends the clips to the 3D view (also used when the view mounts).
  void push() => ref.read(sceneControllerProvider)?.setTracks(state.toJson());

  double? _sourceLength(MediaClip clip) => ref.read(assetsProvider)[clip.assetId]?.duration;

  void _mapCaption(String id, CaptionClip Function(CaptionClip) change) =>
      _set(state.copyWith(captions: [for (final c in state.captions) c.id == id ? change(c) : c]));

  void _mapMedia(ClipRef clip, MediaClip Function(MediaClip) change) {
    final list = [for (final c in state.on(clip.track).cast<MediaClip>()) c.id == clip.id ? change(c) : c];
    _set(clip.track == TrackKind.screen ? state.copyWith(screens: list) : state.copyWith(audio: list));
  }

  void _set(Tracks next) {
    ref.read(editHistoryProvider.notifier).record();
    state = next;
    push();
  }
}

final tracksProvider = NotifierProvider<TracksNotifier, Tracks>(TracksNotifier.new);
