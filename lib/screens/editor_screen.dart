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
import '../widgets/studio/draggable_island.dart';

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
  bool _isInspectorExpanded = true;
  bool _isLeftRailExpanded = true;
  double _currentZoomScale = 0.3;
  bool _isProgrammaticZoom = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onZoomChanged);
  }

  void _onZoomChanged() {
    if (_isProgrammaticZoom) return;
    // Only update from external changes (pinch/scroll via InteractiveViewer)
    final matrixScale = _transformationController.value.getMaxScaleOnAxis();
    final diff = (matrixScale - _currentZoomScale).abs();
    if (diff > 0.01) {
      setState(() => _currentZoomScale = matrixScale);
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onZoomChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(mockupProjectProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Row(
        children: [
          // ─── LEFT RAIL ──────────────────────
          LeftRailWidget(
            isExpanded: _isLeftRailExpanded,
            onToggle: () =>
                setState(() => _isLeftRailExpanded = !_isLeftRailExpanded),
            boundaryKey: _repaintBoundaryKey,
          ),

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
            isExpanded: _isInspectorExpanded,
            isMotionMode: _currentMode == EditorMode.motion,
            onModeChanged: (isMotion) {
              setState(
                () => _currentMode = isMotion
                    ? EditorMode.motion
                    : EditorMode.design,
              );
            },
            onToggle: () {
              setState(() => _isInspectorExpanded = !_isInspectorExpanded);
            },
            boundaryKey: _repaintBoundaryKey,
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
            setState(() => _currentZoomScale = targetScale);
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

              // Project Title — top left of canvas
              Positioned(
                top: AppSpacing.s24,
                left: AppSpacing.s24,
                child: const EditableProjectTitle(),
              ),

              // Rotation Dial — top right
              const Positioned(
                top: AppSpacing.s32,
                right: AppSpacing.s32,
                child: RotationDial(),
              ),

              // Zoom pill — top center
              Positioned(
                top: AppSpacing.s24,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildZoomControls(
                    canvasCenterX,
                    canvasCenterY,
                    () {
                      _updateZoom((_currentZoomScale + 0.1).clamp(0.1, 4.0), canvasCenterX, canvasCenterY);
                    },
                    () {
                      _updateZoom((_currentZoomScale - 0.1).clamp(0.1, 4.0), canvasCenterX, canvasCenterY);
                    },
                  ),
                ),
              ),

              // Video playback controls — bottom center
              if (ref.watch(mockupProjectProvider).isVideo &&
                  _currentMode == EditorMode.design)
                DraggableIsland(
                  initialOffset: Offset(
                    (constraints.maxWidth - 300) / 2,
                    constraints.maxHeight - 100,
                  ),
                  child: const VideoPlaybackControls(),
                ),

              // Motion Timeline Panel — docked at bottom
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

  void _updateZoom(double newScale, double centerX, double centerY) {
    _isProgrammaticZoom = true;
    if (_currentZoomScale == 0) {
      _isProgrammaticZoom = false;
      return;
    }
    final current = _transformationController.value.clone();
    final ratio = newScale / _currentZoomScale;
    current.translate(centerX, centerY, 0.0);
    current.scale(ratio, ratio, 1.0);
    current.translate(-centerX, -centerY, 0.0);
    _transformationController.value = current;
    _isProgrammaticZoom = false;
    setState(() {
      _currentZoomScale = newScale;
    });
  }

  // ═══════════════════════════════════════════════════════════
  // FLOATING ZOOM CONTROLS — Pill UI
  // ═══════════════════════════════════════════════════════════
  Widget _buildZoomControls(
    double centerX,
    double centerY,
    VoidCallback increment,
    VoidCallback decrement,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: decrement,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(
              Icons.remove,
              size: 14,
              color: AppColors.secondaryText,
            ),
            splashRadius: 16,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '${(_currentZoomScale * 100).round()}%',
              textAlign: TextAlign.center,
              style: AppTypography.uiLabel.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton(
            onPressed: increment,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(
              Icons.add,
              size: 14,
              color: AppColors.secondaryText,
            ),
            splashRadius: 16,
          ),
        ],
      ),
    );
  }
}

class EditableProjectTitle extends ConsumerStatefulWidget {
  const EditableProjectTitle({super.key});

  @override
  ConsumerState<EditableProjectTitle> createState() =>
      _EditableProjectTitleState();
}

class _EditableProjectTitleState extends ConsumerState<EditableProjectTitle> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final title = ref.read(mockupProjectProvider).title;
    _controller = TextEditingController(text: title);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _commitTitle();
      }
    });
  }

  void _commitTitle() {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty) {
      ref.read(mockupProjectProvider.notifier).setTitle(newTitle);
    } else {
      // Revert if empty
      _controller.text = ref.read(mockupProjectProvider).title;
    }
    setState(() => _isEditing = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = ref.watch(mockupProjectProvider.select((p) => p.title));

    if (!_isEditing) {
      return GestureDetector(
        onTap: () {
          setState(() => _isEditing = true);
          _controller.text = title;
          _focusNode.requestFocus();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            style: AppTypography.uiBody.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accent),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: AppTypography.uiBody.copyWith(color: Colors.white),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        onSubmitted: (_) => _commitTitle(),
      ),
    );
  }
}
