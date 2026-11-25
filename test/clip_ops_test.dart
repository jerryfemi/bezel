import 'package:bezel/features/timeline/model/clip_ops.dart';
import 'package:bezel/features/timeline/model/clips.dart';
import 'package:bezel/features/timeline/model/tracks.dart';
import 'package:flutter_test/flutter_test.dart';

MediaClip clip(String id, double start, double end, {double inPoint = 0}) =>
    MediaClip(id: id, start: start, end: end, assetId: 'a', inPoint: inPoint);

void main() {
  final track = [clip('a', 0, 4), clip('b', 6, 10), clip('c', 12, 13)];

  test('moving stays between neighbours', () {
    expect(clampStart(track, track[1], 1), 4); // stops at a's end
    expect(clampStart(track, track[1], 5), 5);
    expect(clampStart(track, track[1], 20), 8); // 4 s long, must end by c's start
    expect(clampStart(track, track[0], -3), 0);
  });

  test('left trim moves the in-point and respects the file start', () {
    final b = clip('b', 6, 10, inPoint: 1);
    final t = [track[0], b];
    final r = trimStart(t, b, 7, inPoint: 1, sourceLength: 10);
    expect(r.start, 7);
    expect(r.inPoint, 2);
    final early = trimStart(t, b, 0, inPoint: 1, sourceLength: 10);
    expect(early.start, 5); // file only reaches back 1 s
    expect(early.inPoint, 0);
  });

  test('right trim stops at the file end and the next clip', () {
    expect(trimEnd(track, track[1], 30, sourceLength: 5), 11); // 6 + 5 s of file
    expect(trimEnd(track, track[1], 30), 12); // image: up to clip c
    expect(trimEnd(track, track[1], 0), closeTo(6 + minClipLength, 1e-9));
  });

  test('split only well inside a clip', () {
    expect(canSplit(track[0], 2), isTrue);
    expect(canSplit(track[0], 0.05), isFalse);
    expect(canSplit(track[0], 4), isFalse);
  });

  test('snapping and free space', () {
    expect(snapTo(3.93, [4, 6], 0.1), 4);
    expect(snapTo(3.5, [4, 6], 0.1), 3.5);
    expect(firstFreeStart(track, 2, 1), 4);
    expect(firstFreeStart(track, 2, 3), 13);
  });

  test('tracks save and load, and know their end', () {
    final tracks = Tracks(screens: [clip('x', 2, 9, inPoint: 1.5)]);
    final back = Tracks.fromMap(tracks.toMap().cast<String, dynamic>());
    expect(back.screens.single.inPoint, 1.5);
    expect(back.end, 9);
    expect(clipLength(back, 12), 12);
  });
}
