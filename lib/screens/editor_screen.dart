import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mockup_provider.dart';
import '../widgets/phone_mockup_widget.dart';
import '../widgets/studio/left_rail_widget.dart';
import '../widgets/studio/right_inspector_widget.dart';
import '../widgets/video_playback_controls.dart';
import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_typography.dart';
import '../widgets/studio/rotation_dial.dart';
import '../widgets/studio/timeline_panel.dart';
import '../widgets/studio/checkerboard_painter.dart';

enum EditorMode { design, motion }

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController(Matrix4.identity()..scale(0.3, 0.3, 1.0));
  bool _isInitialScaleSet = false;
  EditorMode _currentMode = EditorMode.design;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
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
                // ─── LEFT RAIL ──────────────────────
                LeftRailWidget(boundaryKey: _repaintBoundaryKey),

                // Thin border between rail and canvas
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),

                // ─── CANVAS (Dominant) ────────────────
                Expanded(child: _buildCanvas(project)),

                // Thin border between canvas and inspector
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),

                // ─── RIGHT INSPECTOR (always visible, collapsible) ───
                RightInspectorWidget(
                  isMotionMode: _currentMode == EditorMode.motion,
                  boundaryKey: _repaintBoundaryKey,
                ),
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
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Row(
        children: [
          // LEFT: Project name and Mode Switcher
          Text('Untitled Mockup', style: AppTypography.uiBody),
          const SizedBox(width: AppSpacing.s32),

          // Mode Switcher
          Container(
            decoration: BoxDecoration(
              color: AppColors.raisedSurface,
              borderRadius: BorderRadius.circular(AppRadius.control),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeTab('DESIGN', EditorMode.design),
                const SizedBox(width: 4),
                _buildModeTab('MOTION', EditorMode.motion),
              ],
            ),
          ),

          // RIGHT: Empty now that tools are in Left Rail
          const Spacer(),
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
            final deviceWidth =
                project.device.screenRect.width +
                (project.device.screenRect.left * 2) +
                128;
            final deviceHeight =
                project.device.screenRect.height +
                (project.device.screenRect.top * 2) +
                128;

            final targetScale = (constraints.maxHeight * 0.7) / deviceHeight;

            final dx = (constraints.maxWidth - (deviceWidth * targetScale)) / 2;
            final dy =
                (constraints.maxHeight - (deviceHeight * targetScale)) / 2;

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
                  scaleEnabled:
                      ref.watch(activeEditorToolProvider) != EditorTool.crop,
                  constrained: false,
                  child: UnconstrainedBox(
                    clipBehavior: Clip.none,
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Builder(
                        builder: (context) {
                          final rotationMagnitude =
                              project.rotationX.abs() +
                              project.rotationY.abs() +
                              project.rotationZ.abs();
                          final dynamicPadding =
                              64.0 +
                              (rotationMagnitude * 800).clamp(0.0, 1500.0);

                          final isTransparent =
                              project.backgroundColor == Colors.transparent;

                          return CustomPaint(
                            painter:
                                isTransparent && !project.isCapturingOverlay
                                ? CheckerboardPainter()
                                : null,
                            child: Container(
                              color: project.isCapturingOverlay || isTransparent
                                  ? Colors.transparent
                                  : project.backgroundColor,
                              padding: EdgeInsets.all(dynamicPadding),
                              child: const PhoneMockupWidget(),
                            ),
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
              if (ref.watch(mockupProjectProvider).isVideo &&
                  _currentMode == EditorMode.design)
                const Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Center(child: VideoPlaybackControls()),
                ),

              // Motion Timeline Panel — bottom
              if (_currentMode == EditorMode.motion)
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: TimelinePanel(),
                ),
            ],
          ),
        );
      },
    );
  }

  // Inspector Panel removed in favor of RightInspectorWidget

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
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 5.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12.0,
                    ),
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

  Widget _buildModeTab(String title, EditorMode mode) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _currentMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.control - 2),
        ),
        child: Text(
          title,
          style: AppTypography.uiLabel.copyWith(
            color: isSelected ? Colors.black : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
