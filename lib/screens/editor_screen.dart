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
import '../widgets/panels/crop_panel.dart';
import '../widgets/video_playback_controls.dart';
import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_typography.dart';
import '../widgets/studio/studio_button.dart';
import '../widgets/studio/rotation_dial.dart';


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
        final bytes = await file.readAsBytes();
        ref.read(videoRawBytesProvider.notifier).state = bytes;
      }
    }
  }

  Future<void> _exportMedia() async {
    final project = ref.read(mockupProjectProvider);

    if (project.isVideo &&
        (project.rotationX != 0 ||
            project.rotationY != 0 ||
            project.rotationZ != 0)) {
      ref.read(mockupProjectProvider.notifier).setRotation(0, 0, 0);
      await Future.delayed(const Duration(milliseconds: 100));
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text('Generating High-Res Image...'),
          ],
        ),
      ),
    );

    // Give the UI time to render the dialog before the heavy work
    await Future.delayed(const Duration(milliseconds: 100));

    final path = await ImageExportService.exportToPng(_repaintBoundaryKey);
    
    // Close the dialog
    if (mounted) Navigator.of(context).pop();

    if (mounted) {
      setState(() => _isExporting = false);
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
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          // ─── TOP BAR (56px) ─────────────────────────────────
          _buildTopBar(),
          
          // ─── MAIN CONTENT ──────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // ─── LEFT RAIL (72px) ──────────────────────
                const LeftRailWidget(),
                
                // Thin border between rail and canvas
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                
                // ─── CANVAS (Dominant ~70%) ────────────────
                Expanded(
                  child: _buildCanvas(project),
                ),
                
                // Thin border between canvas and inspector
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
                
                // ─── RIGHT INSPECTOR (280px) ───────────────
                _buildInspectorPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOP BAR — 56px, extremely quiet
  // ═══════════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Row(
        children: [
          // LEFT: Project name
          Text('Untitled Mockup', style: AppTypography.uiBody),
          
          const Spacer(),
          
          // RIGHT: Media pickers + Export
          _TopBarAction(
            icon: Icons.image_outlined,
            label: 'Image',
            onTap: () => _pickMedia(false),
          ),
          const SizedBox(width: AppSpacing.s8),
          _TopBarAction(
            icon: Icons.videocam_outlined,
            label: 'Video',
            onTap: () => _pickMedia(true),
          ),
          const SizedBox(width: AppSpacing.s16),
          StudioButton(
            label: 'Export',
            icon: Icons.download_rounded,
            isPrimary: true,
            onPressed: _isExporting ? () {} : _exportMedia,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CANVAS — dominant surface, the hero
  // ═══════════════════════════════════════════════════════════
  Widget _buildCanvas(dynamic project) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_isInitialScaleSet && constraints.maxHeight > 0) {
          _isInitialScaleSet = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final project = ref.read(mockupProjectProvider);
            final deviceWidth = project.device.screenRect.width + (project.device.screenRect.left * 2) + 128;
            final deviceHeight = project.device.screenRect.height + (project.device.screenRect.top * 2) + 128;
            
            final targetScale = (constraints.maxHeight * 0.7) / deviceHeight;
            
            final dx = (constraints.maxWidth - (deviceWidth * targetScale)) / 2;
            final dy = (constraints.maxHeight - (deviceHeight * targetScale)) / 2;
            
            final initialTransform = Matrix4.identity()
              ..translate(dx, dy, 0.0)
              ..scale(targetScale, targetScale, 1.0);
              
            _transformationController.value = initialTransform;
          });
        }
        
        final canvasCenterX = constraints.maxWidth / 2;
        final canvasCenterY = constraints.maxHeight / 2;
        
        return Container(
          color: project.backgroundColor,
          child: Stack(
            children: [
              // The interactive canvas with the device mockup
              GestureDetector(
                onPanUpdate: (details) {
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
                  scaleEnabled: ref.watch(activeEditorToolProvider) != EditorTool.crop,
                  constrained: false,
                  child: UnconstrainedBox(
                    clipBehavior: Clip.none,
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Builder(
                        builder: (context) {
                          final rotationMagnitude = project.rotationX.abs() + project.rotationY.abs() + project.rotationZ.abs();
                          final dynamicPadding = 64.0 + (rotationMagnitude * 800).clamp(0.0, 1500.0);
                          
                          return Container(
                            color: project.isCapturingOverlay
                                ? Colors.transparent
                                : project.backgroundColor,
                            padding: EdgeInsets.all(dynamicPadding),
                            child: const PhoneMockupWidget(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // ─── Floating Canvas Controls (Glass Treatment) ───
              
              // Rotation Dial — top right
              const Positioned(
                top: AppSpacing.s32,
                right: AppSpacing.s32,
                child: RotationDial(),
              ),
              
              // Zoom slider — bottom left
              Positioned(
                bottom: AppSpacing.s32,
                left: AppSpacing.s32,
                child: _buildZoomSlider(canvasCenterX, canvasCenterY),
              ),
              
              // Video playback controls — bottom center
              if (ref.watch(mockupProjectProvider).isVideo)
                const Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: VideoPlaybackControls(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // RIGHT INSPECTOR — 280px, contextual
  // ═══════════════════════════════════════════════════════════
  Widget _buildInspectorPanel() {
    return Consumer(
      builder: (context, ref, child) {
        final activeTool = ref.watch(activeEditorToolProvider);
        if (activeTool == EditorTool.device) {
          return const DeviceSelectorPanel();
        } else if (activeTool == EditorTool.background) {
          return const BackgroundPanel();
        } else if (activeTool == EditorTool.crop) {
          return const CropPanel();
        }
        return const SizedBox(width: 280);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FLOATING ZOOM SLIDER — Glass Treatment
  // ═══════════════════════════════════════════════════════════
  Widget _buildZoomSlider(double centerX, double centerY) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(
          color: AppColors.primaryText.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.zoom_out, size: 16, color: AppColors.secondaryText),
          SizedBox(
            width: 150,
            child: ValueListenableBuilder<Matrix4>(
              valueListenable: _transformationController,
              builder: (context, matrix, child) {
                final scale = matrix.getMaxScaleOnAxis();
                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.primaryText,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                  ),
                  child: Slider(
                    value: scale.clamp(0.1, 4.0),
                    min: 0.1,
                    max: 4.0,
                    onChanged: (newScale) {
                      final current = _transformationController.value.clone();
                      final currentScale = current.getMaxScaleOnAxis();
                      final ratio = newScale / currentScale;
                      current.translate(centerX, centerY, 0.0);
                      current.scale(ratio, ratio, 1.0);
                      current.translate(-centerX, -centerY, 0.0);
                      
                      _transformationController.value = current;
                    },
                  ),
                );
              },
            ),
          ),
          Icon(Icons.zoom_in, size: 16, color: AppColors.secondaryText),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TOP BAR ACTION — quiet text+icon button for the top bar
// ═══════════════════════════════════════════════════════════════
class _TopBarAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TopBarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_TopBarAction> createState() => _TopBarActionState();
}

class _TopBarActionState extends State<_TopBarAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s4,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.raisedSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: AppColors.secondaryText),
              const SizedBox(width: AppSpacing.s4),
              Text(widget.label, style: AppTypography.uiLabel.copyWith(
                color: AppColors.secondaryText,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

