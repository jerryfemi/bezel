import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import '../panels/device_selector_panel.dart';
import '../panels/crop_panel.dart';

class LeftRailWidget extends ConsumerStatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final GlobalKey boundaryKey;

  const LeftRailWidget({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.boundaryKey,
  });

  @override
  ConsumerState<LeftRailWidget> createState() => _LeftRailWidgetState();
}

class _LeftRailWidgetState extends ConsumerState<LeftRailWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _widthFactor;

  double _devicePanelHeight = 300.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _widthFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(LeftRailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt width based on available space
        final panelWidth = constraints.maxWidth > 0
            ? constraints.maxWidth.clamp(220.0, 300.0)
            : 260.0;

        return AnimatedBuilder(
          animation: _widthFactor,
          builder: (context, child) {
            final currentWidth =
                40.0 + (panelWidth - 40.0) * _widthFactor.value;
            return SizedBox(
              width: currentWidth,
              child: Stack(
                children: [
                  // The main panel
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: panelWidth,
                    child: Opacity(opacity: _widthFactor.value, child: child),
                  ),
                  // The sticky tab
                  if (_widthFactor.value < 1.0)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 40.0,
                      child: Opacity(
                        opacity: 1.0 - _widthFactor.value,
                        child: _buildStickyTab(),
                      ),
                    ),
                ],
              ),
            );
          },
          child: Container(
            color: AppColors.surface,
            child: Column(
              children: [
                _buildHeader(),
                const Divider(height: 1, color: AppColors.border),
                // Device Selection (top)
                SizedBox(
                  height: _devicePanelHeight,
                  child: const DeviceSelectorPanel(isEmbedded: true),
                ),

                // Draggable Divider
                MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _devicePanelHeight += details.delta.dy;
                        _devicePanelHeight = _devicePanelHeight.clamp(
                          100.0,
                          800.0,
                        );
                      });
                    },
                    child: Container(
                      height: 9, // comfortable hit area
                      color: AppColors.surface,
                      child: const Center(
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                    ),
                  ),
                ),

                // Screenshot + Crop (bottom)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_ScreenshotSection()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyTab() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: IconButton(
        onPressed: widget.onToggle, // will toggle
        icon: const Icon(
          Icons.keyboard_arrow_right,
          size: 20,
          color: AppColors.primaryText,
        ),
        tooltip: 'Expand Assets',
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      child: Row(
        children: [
          Text('ASSETS', style: AppTypography.panelHeader),
          const Spacer(),
          IconButton(
            onPressed: widget.onToggle,
            icon: const Icon(
              Icons.keyboard_arrow_left,
              size: 20,
              color: AppColors.secondaryText,
            ),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            tooltip: 'Collapse Assets',
          ),
        ],
      ),
    );
  }
}

class _ScreenshotSection extends ConsumerWidget {
  Future<void> _pickMedia(WidgetRef ref, BuildContext context) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickMedia();

    if (file != null) {
      final path = file.path.toLowerCase();
      final isVideo =
          path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi');

      ref
          .read(mockupProjectProvider.notifier)
          .setSourceImage(file.path, isVideo: isVideo);

      if (isVideo) {
        final bytes = await file.readAsBytes();
        ref.read(videoRawBytesProvider.notifier).state = bytes;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(mockupProjectProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact Add Media button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _pickMedia(ref, context),
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 18,
              ),
              label: Text('Add Media', style: AppTypography.uiBody),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.panel),
                ),
              ),
            ),
          ),
          if (project.sourceImagePath?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.s16),
            const CropPanel(isEmbedded: true),
          ],
        ],
      ),
    );
  }
}
