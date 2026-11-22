import 'package:flutter_test/flutter_test.dart';

import 'package:bezel/features/motion/model/keyframe.dart';
import 'package:bezel/features/motion/model/segment_reorder.dart';
import 'package:bezel/features/motion/widgets/segment_drag.dart';
import 'package:bezel/features/scene3d/scene_pose.dart';

Keyframe k(String id, double t) => Keyframe(id: id, time: t, pose: ScenePose(turn: t));

void main() {
  // Start, then moves A (1s), B (3s), C (2s).
  final keys = [k('s', 0), k('a', 1), k('b', 4), k('c', 6)];

  test('moving the first move to the end keeps every duration', () {
    final out = reorderSegments(keys, 1, 3);
    expect(out.map((e) => e.id), ['s', 'b', 'c', 'a']);
    expect(out.map((e) => e.time), [0, 3, 5, 6]);
  });

  test('moving the last move to the front', () {
    final out = reorderSegments(keys, 3, 1);
    expect(out.map((e) => e.id), ['s', 'c', 'a', 'b']);
    expect(out.map((e) => e.time), [0, 2, 3, 6]);
  });

  test('the starting keyframe never moves and same-place drops change nothing', () {
    expect(reorderSegments(keys, 2, 2), same(keys));
    expect(reorderSegments(keys, 1, 3).first.id, 's');
  });

  test('drop index counts the other moves left of the pointer', () {
    final mids = [0.5, 2.5, 5.0]; // centres of A, B, C
    expect(dropIndexFor(6, 1, mids), 3); // A dragged past C → end
    expect(dropIndexFor(0, 3, mids), 1); // C dragged to the start
    expect(dropIndexFor(3, 1, mids), 2); // A dropped between B and C
  });
}
