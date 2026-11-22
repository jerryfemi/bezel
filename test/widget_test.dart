import 'package:flutter_test/flutter_test.dart';

import 'package:bezel/features/editor/state/frame_shape.dart';
import 'package:bezel/features/scene3d/device_profile.dart';

void main() {
  test('DeviceProfile reads a prepared profile.json', () {
    final profile = DeviceProfile.fromJson({
      'id': 'iphone-13-pro-max',
      'name': 'iPhone 13 Pro Max',
      'screens': [
        {'id': 'front', 'aspect': 0.4654},
      ],
      'finishes': [
        {'id': 'graphite', 'name': 'Graphite', 'body': '#54524F', 'frame': '#4A4946'},
      ],
      'defaultFinish': 'graphite',
    });

    expect(profile.name, 'iPhone 13 Pro Max');
    expect(profile.screenAspect, closeTo(0.4654, 1e-9));
    expect(profile.finishes.single.body.toARGB32(), 0xFF54524F);
  });

  test('Frame shapes have the aspect their label says', () {
    for (final shape in FrameShape.values) {
      final parts = shape.label.split(':').map(double.parse).toList();
      expect(shape.aspect, closeTo(parts[0] / parts[1], 1e-9));
    }
  });
}
