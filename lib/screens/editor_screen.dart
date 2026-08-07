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
    }
  }

  Future<void> _exportMedia() async {
    final project = ref.read(mockupProjectProvider);
    
    if (project.isVideo) {
      final videoController = ref.read(videoControllerProvider);
      
      if (videoController == null || !videoController.value.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video is not ready yet.')),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false, // Don't allow closing while exporting
        builder: (ctx) => ExportProgressScreen(
          boundaryKey: _repaintBoundaryKey,
          videoController: videoController,
        ),
      );
      return;
    }

    // Image Export Path
    setState(() => _isExporting = true);
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
                child: Center(
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    // We wrap the mockup in a container with the background color 
                    // so the exported image has the correct background.
                    child: Container(
                      color: project.backgroundColor,
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
