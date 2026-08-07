import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/mockup_provider.dart';
import '../widgets/phone_mockup_widget.dart';
import '../services/export/image_export_service.dart';
import '../screens/export_progress_screen.dart';
import '../widgets/panels/left_rail_widget.dart';
import '../widgets/panels/device_selector_panel.dart';
import '../widgets/panels/background_panel.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  final TransformationController _transformationController =
      TransformationController(Matrix4.identity()..scale(0.3, 0.3, 1.0));
  bool _isExporting = false;
  bool _isInitialScaleSet = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(bool isVideo) async {
    final XFile? file = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ref
          .read(mockupProjectProvider.notifier)
          .setSourceImage(file.path, isVideo: isVideo);

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
    if (project.isVideo &&
        (project.rotationX != 0 ||
            project.rotationY != 0 ||
            project.rotationZ != 0)) {
      ref.read(mockupProjectProvider.notifier).setRotation(0, 0, 0);
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Wait for UI to update
    }

    if (project.isVideo) {
      final rawBytes = ref.read(videoRawBytesProvider);

      if (rawBytes == null || rawBytes.isEmpty) {
        if (mounted) setState(() => _isExporting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video data available.')),
        );
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ExportProgressScreen(
          boundaryKey: _repaintBoundaryKey,
          videoRawBytes: rawBytes,
          mockupNotifier: ref.read(mockupProjectProvider.notifier),
          project: project,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export failed.')));
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
          // Left Rail - Icon Tools
          const LeftRailWidget(),

          // Right Panel - Context Sensitive
          Consumer(
            builder: (context, ref, child) {
              final activeTool = ref.watch(activeEditorToolProvider);
              if (activeTool == EditorTool.device) {
                return const DeviceSelectorPanel();
              } else if (activeTool == EditorTool.background) {
                return const BackgroundPanel();
              }
              return const SizedBox(width: 280); // Placeholder
            },
          ),

          // Main Canvas
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (!_isInitialScaleSet && constraints.maxHeight > 0) {
                  _isInitialScaleSet = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final project = ref.read(mockupProjectProvider);
                    // Approximate total height: screen height + top bezel * 2 + 128px padding
                    final deviceHeight = project.device.screenRect.height + (project.device.screenRect.top * 2) + 128;
                    // Target 70% of available vertical space
                    final targetScale = (constraints.maxHeight * 0.7) / deviceHeight;
                    _transformationController.value = Matrix4.identity()..scale(targetScale, targetScale, 1.0);
                  });
                }
                
                final canvasCenterX = constraints.maxWidth / 2;
                final canvasCenterY = constraints.maxHeight / 2;
                return Stack(
                  children: [
                    GestureDetector(
                  onPanUpdate: (details) {
                    // Drag to rotate
                    ref
                        .read(mockupProjectProvider.notifier)
                        .updateRotation(
                          -details.delta.dy * 0.01,
                          details.delta.dx * 0.01,
                          0,
                        );
                  },
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.1,
                    maxScale: 4.0,
                    constrained:
                        false, // Prevents InteractiveViewer from forcing screen constraints
                    child: UnconstrainedBox(
                      // Ensures RepaintBoundary layout size is never clipped
                      clipBehavior: Clip.none,
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        // We wrap the mockup in a container with the background color
                        // so the exported image has the correct background.
                        child: Container(
                          color: project.isCapturingOverlay
                              ? Colors.transparent
                              : project.backgroundColor,
                          padding: const EdgeInsets.all(
                            64,
                          ), // Some padding around the device in export
                          child: const PhoneMockupWidget(),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Floating Zoom Slider
                Positioned(
                  bottom: 32,
                  left: 32,
                  child: _buildZoomSlider(canvasCenterX, canvasCenterY),
                ),
              ],
            );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomSlider(double centerX, double centerY) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xAA16181C), // rgba(22, 24, 28, 0.65)
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x14F5F1E8),
        ), // rgba(245, 241, 232, 0.08)
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.zoom_out, size: 16, color: Colors.white70),
          SizedBox(
            width: 150,
            child: ValueListenableBuilder<Matrix4>(
              valueListenable: _transformationController,
              builder: (context, matrix, child) {
                final scale = matrix.getMaxScaleOnAxis();
                return Slider(
                  value: scale.clamp(0.1, 4.0),
                  min: 0.1,
                  max: 4.0,
                  activeColor: const Color(0xFF4DE8C4),
                  inactiveColor: Colors.white24,
                  onChanged: (newScale) {
                    final current = _transformationController.value.clone();
                    final currentScale = current.getMaxScaleOnAxis();
                    final ratio = newScale / currentScale;
                    // Transform to center, scale, transform back
                    current.translate(centerX, centerY, 0.0);
                    current.scale(ratio, ratio, 1.0);
                    current.translate(-centerX, -centerY, 0.0);
                    
                    _transformationController.value = current;
                  },
                );
              },
            ),
          ),
          const Icon(Icons.zoom_in, size: 16, color: Colors.white70),
        ],
      ),
    );
  }
}
