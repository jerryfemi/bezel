// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'dart:html' as html;
import '../../providers/mockup_provider.dart';
import '../../models/mockup_project.dart';
import '../../widgets/phone_mockup_widget.dart';

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

      // Calculate the 4 projected corners of the video container
      final videoBox =
          videoContainerKey.currentContext?.findRenderObject() as RenderBox?;
      if (videoBox == null) throw Exception('Video container not found');

      final boundaryObj =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundaryObj == null) throw Exception('RepaintBoundary not found');

      final tl = videoBox.localToGlobal(
        const Offset(0, 0),
        ancestor: boundaryObj,
      );
      final tr = videoBox.localToGlobal(
        Offset(videoBox.size.width, 0),
        ancestor: boundaryObj,
      );
      final bl = videoBox.localToGlobal(
        Offset(0, videoBox.size.height),
        ancestor: boundaryObj,
      );
      final br = videoBox.localToGlobal(
        Offset(videoBox.size.width, videoBox.size.height),
        ancestor: boundaryObj,
      );

      final tlX = tl.dx;
      final tlY = tl.dy;
      final trX = tr.dx;
      final trY = tr.dy;
      final blX = bl.dx;
      final blY = bl.dy;
      final brX = br.dx;
      final brY = br.dy;

      final cw = videoBox.size.width.toInt();
      final ch = videoBox.size.height.toInt();

      debugPrint(
        'FFmpeg corners: tl($tlX, $tlY), tr($trX, $trY), bl($blX, $blY), br($brX, $brY)',
      );

      // --- Step 5: Run ---
      onProgress(0.45, 'Encoding Video...');

      final matrix = project.mediaTransform ?? Matrix4.identity();
      final scale = matrix.getMaxScaleOnAxis();
      final tx = matrix.getTranslation().x.toInt();
      final ty = matrix.getTranslation().y.toInt();

      final scaledW = _makeEven((cw * scale).toInt());
      final scaledH = _makeEven((ch * scale).toInt());

      final bgColor = project.backgroundColor;
      final ffmpegColor = bgColor == Colors.transparent
          ? 'black@0.0'
          : '0x${bgColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

      final filterComplex =
          // 1. BoxFit.cover equivalent for the input video
          '[0:v]scale=w=$cw:h=$ch:force_original_aspect_ratio=increase,crop=$cw:$ch[covered];'
          // 2. Apply InteractiveViewer zoom
          '[covered]scale=w=$scaledW:h=$scaledH[zoomed];'
          // 3. Create transparent canvas matching the un-transformed screen hole
          'color=c=black@0.0:s=${cw}x${ch},format=rgba[trans_bg];'
          // 4. Apply InteractiveViewer pan (shortest=1 stops the infinite color stream when video ends)
          '[trans_bg][zoomed]overlay=x=$tx:y=$ty:format=auto:shortest=1[flat_video];'
          // 5. Stretch to full canvas size so perspective filter maps the corners correctly
          '[flat_video]scale=w=$canvasW:h=$canvasH[stretched_video];'
          // 6. Apply 3D perspective mapping
          '[stretched_video]perspective=x0=$tlX:y0=$tlY:x1=$trX:y1=$trY:x2=$blX:y2=$blY:x3=$brX:y3=$brY:sense=destination[warped_video];'
          // 7. Create solid background
          'color=c=$ffmpegColor:s=${canvasW}x$canvasH[solid_bg];'
          // 8. Composite video on background (shortest=1 stops the infinite background color)
          '[solid_bg][warped_video]overlay=x=0:y=0:shortest=1[vid_on_bg];'
          // 9. Composite bezel on top
          '[vid_on_bg][1:v]overlay=x=0:y=0:shortest=1[out]';

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

      // Build FFmpeg arguments
      final List<String> args = [];

      // If trim start is set, apply input seek
      if (project.trimStartTime != null) {
        args.addAll(['-ss', '${project.trimStartTime!.inMilliseconds / 1000}']);
      }

      // If trim end is set, specify duration to cut off
      if (project.trimStartTime != null && project.trimEndTime != null) {
        final duration = project.trimEndTime! - project.trimStartTime!;
        args.addAll(['-t', '${duration.inMilliseconds / 1000}']);
      } else if (project.trimEndTime != null) {
        args.addAll(['-to', '${project.trimEndTime!.inMilliseconds / 1000}']);
      }

      args.addAll([
        '-i',
        'input.mp4',
        '-loop',
        '1',
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

      // Execute FFmpeg (ffmpeg_wasm run() returns void)
      await _ffmpeg.run(args);

      onProgress(0.92, 'Finalizing...');

      // --- Step 6: Output ---
      Uint8List? outBytes;
      try {
        outBytes = _ffmpeg.readFile('output.mp4');
      } catch (_) {
        // readFile throws if the file doesn't exist (i.e. FFmpeg crashed)
      }

      if (outBytes == null || outBytes.isEmpty) {
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
