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
  /// Flow:
  /// 1. Load FFmpeg WASM engine
  /// 2. Set isCapturingOverlay=true, wait a frame, capture bezel overlay PNG
  /// 3. Set isCapturingOverlay=false to restore video preview
  /// 4. Write input.mp4 (raw video) and overlay.png to FFmpeg's virtual FS
  /// 5. Run FFmpeg to scale video, pad to canvas size, overlay bezel on top
  /// 6. Download the output.mp4
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

      // Hide the video by setting the capture flag
      mockupNotifier.setCapturingOverlay(true);

      // Wait for Flutter to rebuild with the video hidden
      await Future.delayed(const Duration(milliseconds: 200));

      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        mockupNotifier.setCapturingOverlay(false);
        throw Exception('Could not find RepaintBoundary');
      }

      // Capture the bezel-only overlay at high quality
      final overlayImage = await boundary.toImage(pixelRatio: 2.0);
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
      // The overlay PNG is what RepaintBoundary captured (the full canvas with bezel).
      // The video needs to be scaled to fit inside the screen area of the bezel,
      // then the bezel PNG is overlaid on top.
      //
      // Canvas dimensions must be even for yuv420p
      final canvasW = (overlayImage.width.toInt() ~/ 2) * 2;
      final canvasH = (overlayImage.height.toInt() ~/ 2) * 2;

      const double pixelRatio = 2.0;
      const double editorPadding = 64.0;
      const double bezelPadding = 20.0;

      // Screen dimensions must be even
      final screenW = ((device.screenRect.width * pixelRatio).toInt() ~/ 2) * 2;
      final screenH = ((device.screenRect.height * pixelRatio).toInt() ~/ 2) * 2;

      // Offset
      final offsetX = ((editorPadding + bezelPadding) * pixelRatio).toInt();
      final offsetY = ((editorPadding + bezelPadding) * pixelRatio).toInt();

      // Convert background color to hex for FFmpeg pad filter
      // FFmpeg requires 0xRRGGBB or #RRGGBB
      const bgColor = '0x1E1E1E';

      // --- Step 5: Run FFmpeg compositing ---
      onProgress(0.45, 'Encoding Video...');

      final filterComplex =
          '[0:v]scale=$screenW:$screenH:force_original_aspect_ratio=decrease,'
          'pad=$screenW:$screenH:(ow-iw)/2:(oh-ih)/2:color=$bgColor[scaled];'
          '[scaled]pad=$canvasW:$canvasH:$offsetX:$offsetY:color=$bgColor[padded];'
          '[padded][1:v]overlay=0:0[out]';

      _ffmpeg.setProgress((progress) {
        final ffmpegProgress = progress.ratio;
        onProgress(
          0.45 + (0.45 * ffmpegProgress),
          'Encoding Video... ${(ffmpegProgress * 100).toInt()}%',
        );
      });

      await _ffmpeg.runCommand(
        '-i input.mp4 -i overlay.png '
        '-filter_complex "$filterComplex" '
        '-map "[out]" -map 0:a? '
        '-c:v libx264 -pix_fmt yuv420p -preset fast '
        '-y output.mp4',
      );

      onProgress(0.92, 'Finalizing...');

      // --- Step 6: Read output and trigger download ---
      final Uint8List outBytes = _ffmpeg.readFile('output.mp4');

      _downloadWeb(
        outBytes,
        'bezel_mockup_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      // Cleanup virtual file system
      _ffmpeg.unlink('input.mp4');
      _ffmpeg.unlink('overlay.png');
      _ffmpeg.unlink('output.mp4');

      onProgress(1.0, 'Export Complete!');
    } catch (e) {
      // Make sure we restore the video if something goes wrong
      try {
        mockupNotifier.setCapturingOverlay(false);
      } catch (_) {}
      debugPrint('Export failed: $e');
      throw Exception('Video export failed: $e');
    }
  }

  void _downloadWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
