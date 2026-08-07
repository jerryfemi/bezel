import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../services/export/web_video_export_service.dart';

class ExportProgressScreen extends StatefulWidget {
  final GlobalKey boundaryKey;
  final VideoPlayerController videoController;

  const ExportProgressScreen({
    super.key,
    required this.boundaryKey,
    required this.videoController,
  });

  @override
  State<ExportProgressScreen> createState() => _ExportProgressScreenState();
}

class _ExportProgressScreenState extends State<ExportProgressScreen> {
  final WebVideoExportService _exportService = WebVideoExportService();
  double _progress = 0.0;
  String _statusMessage = "Initializing Encoder...";
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _startExport();
  }

  Future<void> _startExport() async {
    try {
      await _exportService.exportVideo(
        widget.boundaryKey,
        widget.videoController,
        (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
              if (progress < 0.1) {
                _statusMessage = "Loading FFmpeg Engine...";
              } else if (progress < 0.85) {
                _statusMessage =
                    "Capturing Frames (${(progress * 100).toInt()}%)...";
              } else if (progress < 1.0) {
                _statusMessage = "Encoding MP4...";
              } else {
                _statusMessage = "Export Complete!";
              }
            });

            if (progress >= 1.0) {
              // Close modal after success
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) Navigator.of(context).pop();
              });
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _statusMessage = "Export Failed: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Exporting Video',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Colors.grey.shade800,
              color: _isError ? Colors.red : Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: TextStyle(color: _isError ? Colors.red : Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (_isError) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
