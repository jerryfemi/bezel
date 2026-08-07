// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
// ignore: deprecated_member_use
import 'dart:html' as html;

class ImageExportService {
  static Future<String?> exportToPng(GlobalKey boundaryKey) async {
    try {
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) return null;

      if (kIsWeb) {
        _downloadWeb(
          pngBytes,
          'bezel_mockup_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        return 'Exported successfully to Downloads';
      }

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/mockup_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);

      return path;
    } catch (e) {
      debugPrint('Error exporting image: $e');
      return null;
    }
  }

  static void _downloadWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
