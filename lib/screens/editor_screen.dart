import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/mockup_provider.dart';
import '../widgets/phone_mockup_widget.dart';
import '../services/export/image_export_service.dart';
import '../screens/export_progress_screen.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  bool _isExporting = false;

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? file = isVideo 
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ref.read(mockupProjectProvider.notifier).setSourceImage(file.path, isVideo: isVideo);
      
      if (isVideo) {
        // Store the raw video bytes for FFmpeg compositing
        final bytes = await file.readAsBytes();
        ref.read(videoRawBytesProvider.notifier).state = bytes;
      }
    }
  }

  Future<void> _exportMedia() async {
    final project = ref.read(mockupProjectProvider);

    // Force reset rotation for video exports since FFmpeg composite is flat 2D
    if (project.isVideo && (project.rotationX != 0 || project.rotationY != 0 || project.rotationZ != 0)) {
      ref.read(mockupProjectProvider.notifier).setRotation(0, 0, 0);
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for UI to update
    }

    if (project.isVideo) {
      final rawBytes = ref.read(videoRawBytesProvider);
      
      if (rawBytes == null || rawBytes.isEmpty) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video data available.')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ExportProgressScreen(
          boundaryKey: _repaintBoundaryKey,
          videoRawBytes: rawBytes,
          mockupNotifier: ref.read(mockupProjectProvider.notifier),
          device: project.device,
          backgroundColor: project.backgroundColor,
        ),
      );
      setState(() => _isExporting = false);
      return;
    }

    // Image Export Path
    final path = await ImageExportService.exportToPng(_repaintBoundaryKey);
    setState(() => _isExporting = false);

    if (mounted) {
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported successfully to $path')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(mockupProjectProvider);

    return Scaffold(
      backgroundColor: project.backgroundColor,
      appBar: AppBar(
        title: const Text('Bezel'),
        actions: [
          TextButton.icon(
            onPressed: () => _pickMedia(false),
            icon: const Icon(Icons.image),
            label: const Text('Add Image'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _pickMedia(true),
            icon: const Icon(Icons.videocam),
            label: const Text('Add Video'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _isExporting ? null : _exportMedia,
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: const Text('Export Mockup'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar - Controls
          Container(
            width: 300,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rotation', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSlider('X Axis', project.rotationX, (val) {
                  ref.read(mockupProjectProvider.notifier).setRotation(val, project.rotationY, project.rotationZ);
                }),
                _buildSlider('Y Axis', project.rotationY, (val) {
                  ref.read(mockupProjectProvider.notifier).setRotation(project.rotationX, val, project.rotationZ);
                }),
                _buildSlider('Z Axis', project.rotationZ, (val) {
                  ref.read(mockupProjectProvider.notifier).setRotation(project.rotationX, project.rotationY, val);
                }),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.read(mockupProjectProvider.notifier).setRotation(0, 0, 0);
                  },
                  child: const Text('Reset Rotation'),
                )
              ],
            ),
          ),
          // Main Canvas
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                // Drag to rotate
                ref.read(mockupProjectProvider.notifier).updateRotation(
                  -details.delta.dy * 0.01,
                  details.delta.dx * 0.01,
                  0,
                );
              },
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.1,
                maxScale: 4.0,
                constrained: false, // Prevents InteractiveViewer from forcing screen constraints
                child: UnconstrainedBox( // Ensures RepaintBoundary layout size is never clipped
                  clipBehavior: Clip.none,
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    // We wrap the mockup in a container with the background color 
                    // so the exported image has the correct background.
                    child: Container(
                      color: project.isCapturingOverlay ? Colors.transparent : project.backgroundColor,
                      padding: const EdgeInsets.all(64), // Some padding around the device in export
                      child: const PhoneMockupWidget(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: -3.14, // -pi
          max: 3.14,  // pi
          onChanged: onChanged,
        ),
      ],
    );
  }
}
