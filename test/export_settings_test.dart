import 'package:flutter_test/flutter_test.dart';

import 'package:bezel/features/editor/state/frame_shape.dart';
import 'package:bezel/features/export/export_settings.dart';

void main() {
  test('sizes follow the frame shape and quality', () {
    const s = ExportSettings(quality: ExportQuality.hd);
    expect(s.sizeFor(FrameShape.landscape), (1920, 1080));
    expect(s.sizeFor(FrameShape.vertical), (1080, 1920));
    expect(s.sizeFor(FrameShape.square), (1080, 1080));
    expect(s.sizeFor(FrameShape.portrait), (1080, 1350));
    expect(const ExportSettings(quality: ExportQuality.uhd).sizeFor(FrameShape.landscape), (3840, 2160));
  });

  test('every size is even, as H.264 requires', () {
    for (final q in ExportQuality.values) {
      for (final shape in FrameShape.values) {
        final (w, h) = ExportSettings(quality: q).sizeFor(shape);
        expect(w.isEven && h.isEven, isTrue, reason: '$q $shape gave $w×$h');
      }
    }
  });

  test('GIFs stay small whatever the quality', () {
    const gif = ExportSettings(format: ExportFormat.gif, quality: ExportQuality.uhd);
    expect(gif.sizeFor(FrameShape.landscape), (960, 540));
  });
}
