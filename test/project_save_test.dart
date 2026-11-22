import 'dart:convert';

import 'package:bezel/features/motion/model/keyframe.dart';
import 'package:bezel/features/motion/model/motion_easing.dart';
import 'package:bezel/features/projects/model/project_doc.dart';
import 'package:bezel/features/scene3d/scene_pose.dart';
import 'package:bezel/features/scene3d/scene_specs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('caption survives a save and load', () {
    const caption = CaptionSpec(
      enabled: true, headline: 'Ship it', subtitle: 'Now', side: CaptionSide.right,
      font: CaptionFont.archivo, align: CaptionAlign.center, size: 1.4, subSize: 0.8,
      dx: 0.1, dy: -0.05, subDx: 0.2, subDy: 0.3, editing: CaptionPart.subtitle,
    );
    final back = CaptionSpec.fromMap(jsonDecode(jsonEncode(caption.toMap())) as Map<String, dynamic>);
    expect(back.toMap(), caption.toMap());
    expect(back.editing, isNull); // typing state is never saved
  });

  test('keyframe survives a save and load', () {
    const key = Keyframe(
        id: 'a', time: 1.5, pose: ScenePose(turn: 30, tilt: -8, zoom: 1.2),
        easing: MotionEasing(EasingKind.spring, bounce: 0.2));
    final back = Keyframe.fromMap('b', jsonDecode(jsonEncode(key.toJson())) as Map<String, dynamic>);
    expect(back.toJson(), key.toJson());
  });

  test('project doc reads old saves with missing fields', () {
    final doc = ProjectDoc.decode('p1', '{"title":"Old"}');
    expect(doc.title, 'Old');
    expect(doc.thumbnail, isNull);
    expect(doc.section('caption'), isNull);
  });
}
