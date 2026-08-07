// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;

class WebVideoExportService {
  late final FFmpeg _ffmpeg = createFFmpeg(CreateFFmpegParam(
    log: true, 
    corePath: 'https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js'
  ));
  
  // Progress callback: returns a value between 0.0 and 1.0
  Future<void> exportVideo(
    GlobalKey boundaryKey, 
    VideoPlayerController videoController, 
    ValueChanged<double> onProgress,
  ) async {
    try {
      if (!_ffmpeg.isLoaded()) {
        onProgress(0.05); // Initial loading state
        await _ffmpeg.load();
      }

      // 1. Prepare video playback
      final originalIsPlaying = videoController.value.isPlaying;
      if (originalIsPlaying) {
        await videoController.pause();
      }
      
      final duration = videoController.value.duration;
      if (duration.inMilliseconds == 0) {
        throw Exception("Video duration is unknown");
      }

      // We will capture at 10 fps to keep the web memory usage reasonable
      const int fps = 10;
      final int frameCount = (duration.inMilliseconds / 1000 * fps).ceil();
      
      onProgress(0.1);

      // --- FRAME CAPTURE LOOP ---
      for (int i = 0; i < frameCount; i++) {
        // Calculate timestamp for this frame
        final frameTimeMs = (i * 1000 / fps).round();
        await videoController.seekTo(Duration(milliseconds: frameTimeMs));
        
        // Wait for the web texture to actually render the new frame onto the canvas.
        // 150ms is usually enough for the HTML <video> tag to pipe the frame to WebGL.
        await Future.delayed(const Duration(milliseconds: 150));
        
        final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) throw Exception("Could not find RepaintBoundary");

        final image = await boundary.toImage(pixelRatio: 2.0); // 2.0 for performance vs quality
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData?.buffer.asUint8List();

        if (pngBytes != null) {
          _ffmpeg.writeFile('frame_$i.png', pngBytes);
        }

        // Update progress: 10% to 80% is frame capture
        onProgress(0.1 + (0.7 * (i / frameCount)));
      }

      // Restore playback
      await videoController.seekTo(Duration.zero);
      if (originalIsPlaying) {
        await videoController.play();
      }

      onProgress(0.85); // Encoding started

      // --- FFMPEG ENCODING ---
      await _ffmpeg.run([
        '-framerate', '$fps',
        '-i', 'frame_%d.png',
        '-c:v', 'libx264',
        '-pix_fmt', 'yuv420p',
        'output.mp4'
      ]);

      onProgress(0.95);

      final Uint8List outBytes = _ffmpeg.readFile('output.mp4');
      
      // --- TRIGGER DOWNLOAD ---
      _downloadWeb(outBytes, 'bezel_mockup_${DateTime.now().millisecondsSinceEpoch}.mp4');

      // Cleanup virtual file system to free memory
      for (int i = 0; i < frameCount; i++) {
        _ffmpeg.unlink('frame_$i.png');
      }
      _ffmpeg.unlink('output.mp4');

      onProgress(1.0); // Done!
    } catch (e) {
      debugPrint('Export failed: $e');
      throw Exception('Video export failed: $e');
    }
  }

  void _downloadWeb(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
