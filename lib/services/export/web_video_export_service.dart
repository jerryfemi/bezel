// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'dart:html' as html;
import '../../models/device_spec.dart';
import '../../providers/mockup_provider.dart';

class WebVideoExportService {
  late final FFmpeg _ffmpeg = createFFmpeg(CreateFFmpegParam(
    log: true,
    corePath: 'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js',
  ));

  /// Exports a video with the bezel overlay composited on top using FFmpeg.
  ///
  /// Strategy: First do a simple test encode to verify FFmpeg works,
  /// then do the full composite with overlay.
  Future<void> exportVideo({
    required GlobalKey boundaryKey,
    required Uint8List videoRawBytes,
    required MockupProjectNotifier mockupNotifier,
    required DeviceSpec device,
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

      // Hide the video so RepaintBoundary only captures the bezel frame
      mockupNotifier.setCapturingOverlay(true);

      // Wait for Flutter to rebuild with the video hidden
      await Future.delayed(const Duration(milliseconds: 300));

      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        mockupNotifier.setCapturingOverlay(false);
        throw Exception('Could not find RepaintBoundary');
      }

      // Capture at 1x pixel ratio to reduce memory pressure in WASM
      final overlayImage = await boundary.toImage(pixelRatio: 1.0);
      final overlayByteData =
          await overlayImage.toByteData(format: ui.ImageByteFormat.png);
      final overlayPng = overlayByteData?.buffer.asUint8List();

      // Restore video immediately
      mockupNotifier.setCapturingOverlay(false);

      if (overlayPng == null) {
        throw Exception('Failed to capture bezel overlay');
      }

      onProgress(0.25, 'Bezel Captured');

      // --- Step 3: Write files to FFmpeg virtual FS ---
      onProgress(0.30, 'Preparing Files...');
      _ffmpeg.writeFile('input.mp4', videoRawBytes);
      _ffmpeg.writeFile('overlay.png', overlayPng);

      onProgress(0.40, 'Files Ready');

      // --- Step 4: Calculate dimensions ---
      // All dimensions must be even for yuv420p / libx264.
      // We use ~/ 2 * 2 to force even numbers.
      
      // The overlay image dimensions at 1x pixel ratio
      final canvasW = _makeEven(overlayImage.width);
      final canvasH = _makeEven(overlayImage.height);

      // Screen area dimensions (where the video goes inside the bezel).
      // At 1x pixel ratio, these match the logical device screen size.
      final screenW = _makeEven(device.screenRect.width.toInt());
      final screenH = _makeEven(device.screenRect.height.toInt());

      // Offset from canvas top-left to screen area top-left.
      // The editor adds 64px padding, the bezel widget adds 20px padding.
      const int editorPadding = 64;
      const int bezelPadding = 20;
      final offsetX = editorPadding + bezelPadding;
      final offsetY = editorPadding + bezelPadding;

      debugPrint('FFmpeg dimensions: canvas=${canvasW}x$canvasH, '
          'screen=${screenW}x$screenH, offset=$offsetX,$offsetY');

      // --- Step 5: Run FFmpeg compositing ---
      onProgress(0.45, 'Encoding Video...');

      // Filter chain:
      // 1. Scale the input video to fit the screen area
      // 2. Pad it to the full canvas size, positioned at the screen offset
      // 3. Overlay the bezel PNG on top (bezel has transparent screen cutout)
      //
      // We use explicit integer values to avoid any fractional pixel issues.
      final filterComplex =
          '[0:v]scale=${screenW}:${screenH}:force_original_aspect_ratio=decrease,pad=${screenW}:${screenH}:(ow-iw)/2:(oh-ih)/2:color=0x1E1E1E[scaled];'
          '[scaled]pad=${canvasW}:${canvasH}:${offsetX}:${offsetY}:color=0x1E1E1E[padded];'
          '[padded][1:v]overlay=0:0[out]';

      debugPrint('FFmpeg filter: $filterComplex');

      _ffmpeg.setProgress((progress) {
        final ffmpegProgress = progress.ratio;
        if (ffmpegProgress > 0) {
          onProgress(
            0.45 + (0.45 * ffmpegProgress),
            'Encoding Video... ${(ffmpegProgress * 100).toInt()}%',
          );
        }
      });

      await _ffmpeg.run([
        '-i', 'input.mp4',
        '-i', 'overlay.png',
        '-filter_complex', filterComplex,
        '-map', '[out]',
        '-an',              // Strip audio for v1 (avoids codec compatibility issues in WASM)
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-preset', 'ultrafast',  // Fastest preset to minimize WASM memory pressure
        '-crf', '28',            // Slightly lower quality = much less memory
        '-y', 'output.mp4',
      ]);

      onProgress(0.92, 'Finalizing...');

      // --- Step 6: Read output and trigger download ---
      // Check if the output file exists by attempting to read it.
      // If FFmpeg failed silently, this will throw and we'll catch it below.
      final Uint8List outBytes = _ffmpeg.readFile('output.mp4');

      if (outBytes.isEmpty) {
        throw Exception('FFmpeg produced an empty output file');
      }

      debugPrint('Export successful: ${outBytes.length} bytes');

      _downloadWeb(
        outBytes,
        'bezel_mockup_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      // Cleanup virtual file system to free WASM memory
      try {
        _ffmpeg.unlink('input.mp4');
        _ffmpeg.unlink('overlay.png');
        _ffmpeg.unlink('output.mp4');
      } catch (_) {}

      onProgress(1.0, 'Export Complete!');
    } catch (e) {
      // Restore the video if something goes wrong
      try {
        mockupNotifier.setCapturingOverlay(false);
      } catch (_) {}
      debugPrint('Export failed: $e');
      throw Exception('Video export failed: $e');
    }
  }

  /// Forces a dimension to be even (required by libx264 / yuv420p).
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
