// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'dart:html' as html;
import '../../providers/mockup_provider.dart';
import '../../models/mockup_project.dart';

class WebVideoExportService {
  late final FFmpeg _ffmpeg = createFFmpeg(
    CreateFFmpegParam(
      log: true,
      corePath: 'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js',
    ),
  );

  Future<void> exportVideo({
    required GlobalKey boundaryKey,
    required Uint8List videoRawBytes,
    required MockupProjectNotifier mockupNotifier,
    required MockupProject project,
    required void Function(double progress, String message) onProgress,
  }) async {
    try {
      // --- Step 1: Load FFmpeg ---
      onProgress(0.05, 'Loading FFmpeg Engine...');
      if (!_ffmpeg.isLoaded()) {
        await _ffmpeg.load();
      }
      onProgress(0.10, 'FFmpeg Ready');

      // --- Step 2: Capture bezel overlay ---
      onProgress(0.15, 'Capturing Bezel Overlay...');

      mockupNotifier.setCapturingOverlay(true);
      await Future.delayed(const Duration(milliseconds: 300));

      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        mockupNotifier.setCapturingOverlay(false);
        throw Exception('Could not find RepaintBoundary');
      }

      final overlayImage = await boundary.toImage(pixelRatio: 1.0);
      final overlayByteData = await overlayImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final overlayPng = overlayByteData?.buffer.asUint8List();

      mockupNotifier.setCapturingOverlay(false);

      if (overlayPng == null) {
        throw Exception('Failed to capture bezel overlay');
      }
      onProgress(0.25, 'Bezel Captured');

      // --- Step 3: Write files ---
      onProgress(0.30, 'Preparing Files...');
      _ffmpeg.writeFile('input.mp4', videoRawBytes);
      _ffmpeg.writeFile('overlay.png', overlayPng);
      onProgress(0.40, 'Files Ready');

      // --- Step 4: Dimensions ---
      final canvasW = _makeEven(overlayImage.width);
      final canvasH = _makeEven(overlayImage.height);
      final screenW = _makeEven(project.device.screenRect.width.toInt());
      final screenH = _makeEven(project.device.screenRect.height.toInt());
      final offsetX = 64 + 20;
      final offsetY = 64 + 20;

      debugPrint(
        'FFmpeg dimensions: canvas=${canvasW}x$canvasH, screen=${screenW}x$screenH, offset=$offsetX,$offsetY',
      );

      // --- Step 5: Run ---
      onProgress(0.45, 'Encoding Video...');

      // Strict key=value filter complex to avoid any parsing failures
      final effectiveColor = project.backgroundColor == Colors.transparent ? Colors.black : project.backgroundColor;
      final bgColorHex = effectiveColor.value.toRadixString(16).padLeft(8, '0').substring(2, 8);
      final ffmpegColor = '0x$bgColorHex';
      
      final matrix = project.mediaTransform ?? Matrix4.identity();
      final scale = matrix.getMaxScaleOnAxis();
      final tx = matrix.getTranslation().x;
      final ty = matrix.getTranslation().y;
      
      final scaledW = _makeEven((screenW * scale).toInt());
      final scaledH = _makeEven((screenH * scale).toInt());
      final finalX = (offsetX + tx).toInt();
      final finalY = (offsetY + ty).toInt();

      final filterComplex =
          'color=c=$ffmpegColor:s=${canvasW}x${canvasH}[bg];'
          '[0:v]scale=w=$screenW:h=$screenH:force_original_aspect_ratio=increase,crop=$screenW:$screenH[covered];'
          '[covered]scale=w=$scaledW:h=$scaledH[scaled];'
          '[bg][scaled]overlay=x=$finalX:y=$finalY:format=auto[vid_on_bg];'
          '[vid_on_bg][1:v]overlay=x=0:y=0[out]';

      debugPrint('FFmpeg filter: $filterComplex');

      // Track all logs so we don't just see the final "run FS.readFile" message
      List<String> ffmpegLogs = [];
      _ffmpeg.setLogger((logger) {
        ffmpegLogs.add(logger.message);
        debugPrint('FFmpeg Log: ${logger.message}');
      });

      _ffmpeg.setProgress((progress) {
        if (progress.ratio > 0) {
          onProgress(
            0.45 + (0.45 * progress.ratio),
            'Encoding Video... ${(progress.ratio * 100).toInt()}%',
          );
        }
      });

      // Execute FFmpeg (ffmpeg_wasm run() returns void)
      await _ffmpeg.run([
        '-i',
        'input.mp4',
        '-i',
        'overlay.png',
        '-filter_complex',
        filterComplex,
        '-map',
        '[out]',
        '-an',
        '-c:v',
        'libx264',
        '-pix_fmt',
        'yuv420p',
        '-preset',
        'ultrafast',
        '-crf',
        '28',
        '-y',
        'output.mp4',
      ]);

      onProgress(0.92, 'Finalizing...');

      // --- Step 6: Output ---
      final Uint8List outBytes = _ffmpeg.readFile('output.mp4');

      if (outBytes.isEmpty) {
        // Find the actual crash reason from the log buffer
        final realLogs = ffmpegLogs
            .where((l) => !l.contains('FS.readFile'))
            .toList();
        final errorMsg = realLogs.length > 10
            ? realLogs.sublist(realLogs.length - 10).join('\n')
            : realLogs.join('\n');
        throw Exception('FFmpeg Crash Log:\n$errorMsg');
      }

      debugPrint('Export successful: ${outBytes.length} bytes');
      _downloadWeb(
        outBytes,
        'bezel_mockup_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      try {
        _ffmpeg.unlink('input.mp4');
        _ffmpeg.unlink('overlay.png');
        _ffmpeg.unlink('output.mp4');
      } catch (_) {}

      onProgress(1.0, 'Export Complete!');
    } catch (e) {
      try {
        mockupNotifier.setCapturingOverlay(false);
      } catch (_) {}
      debugPrint('Export failed: $e');
      throw Exception('Video export failed: $e');
    }
  }

  int _makeEven(int value) => (value ~/ 2) * 2;

  void _downloadWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
