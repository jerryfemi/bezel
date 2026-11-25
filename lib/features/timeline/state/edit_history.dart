import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/model/motion_timeline.dart';
import '../../motion/state/timeline_provider.dart';
import '../model/tracks.dart';
import 'tracks_provider.dart';

typedef _Snapshot = ({Tracks tracks, MotionTimeline motion});

/// Undo and redo for timeline edits (clips and keyframes together).
/// Edits made in quick succession, like the steps of one drag, count as one.
class EditHistory extends Notifier<({bool canUndo, bool canRedo})> {
  static const _coalesce = Duration(milliseconds: 500);
  static const _limit = 80;

  final _undo = <_Snapshot>[];
  final _redo = <_Snapshot>[];
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  bool _applying = false;

  @override
  ({bool canUndo, bool canRedo}) build() => (canUndo: false, canRedo: false);

  _Snapshot get _now => (tracks: ref.read(tracksProvider), motion: ref.read(timelineProvider));

  /// Call before changing clips or keyframes.
  void record() {
    if (_applying) return;
    final now = DateTime.now();
    final fresh = now.difference(_last) > _coalesce;
    _last = now;
    if (!fresh) return;
    _undo.add(_now);
    if (_undo.length > _limit) _undo.removeAt(0);
    _redo.clear();
    _publish();
  }

  /// Starts a new undo step even if the last edit was moments ago.
  void breakStep() => _last = DateTime.fromMillisecondsSinceEpoch(0);

  void undo() => _step(_undo, _redo);
  void redo() => _step(_redo, _undo);

  /// Forgets everything (opening another project).
  void clear() {
    _undo.clear();
    _redo.clear();
    _publish();
  }

  void _step(List<_Snapshot> from, List<_Snapshot> to) {
    if (from.isEmpty) return;
    to.add(_now);
    final s = from.removeLast();
    _applying = true;
    try {
      ref.read(tracksProvider.notifier).restore(s.tracks);
      ref.read(timelineProvider.notifier).restore(s.motion);
    } finally {
      _applying = false;
    }
    breakStep();
    _publish();
  }

  void _publish() => state = (canUndo: _undo.isNotEmpty, canRedo: _redo.isNotEmpty);
}

final editHistoryProvider =
    NotifierProvider<EditHistory, ({bool canUndo, bool canRedo})>(EditHistory.new);
