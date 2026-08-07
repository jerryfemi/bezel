import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageExportService {
  static Future<String?> exportToPng(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) return null;

      if (kIsWeb) {
        debugPrint('Web export requires creating an anchor tag download. Returning null for now.');
        // For a full web implementation, we would use package:web here.
        return 'Web Export Not Fully Supported Yet';
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/mockup_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);

      return path;
    } catch (e) {
      debugPrint('Error exporting image: $e');
      return null;
    }
  }
}
