import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/device_spec.dart';
import '../../providers/mockup_provider.dart';
import '../../services/export/web_video_export_service.dart';

class ExportProgressScreen extends StatefulWidget {
  final GlobalKey boundaryKey;
  final Uint8List videoRawBytes;
  final MockupProjectNotifier mockupNotifier;
  final DeviceSpec device;

  const ExportProgressScreen({
    super.key,
    required this.boundaryKey,
    required this.videoRawBytes,
    required this.mockupNotifier,
    required this.device,
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
        boundaryKey: widget.boundaryKey,
        videoRawBytes: widget.videoRawBytes,
        mockupNotifier: widget.mockupNotifier,
        device: widget.device,
        onProgress: (progress, message) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _statusMessage = message;

              if (progress >= 1.0) {
                _statusMessage = "Export Complete!";
              }
            });

            if (progress >= 1.0) {
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
          _statusMessage = 'Export Failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Exporting Video',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isError ? Colors.red : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: TextStyle(color: _isError ? Colors.red : Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (_isError) ...[
              const SizedBox(height: 16),
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
