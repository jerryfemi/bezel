import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import '../panels/device_selector_panel.dart';
import '../panels/crop_panel.dart';
import 'studio_button.dart';

class LeftRailWidget extends ConsumerStatefulWidget {
  final bool isExpanded;
  final VoidCallback onCollapse;
  final GlobalKey boundaryKey;

  const LeftRailWidget({
    super.key,
    required this.isExpanded,
    required this.onCollapse,
    required this.boundaryKey,
  });

  @override
  ConsumerState<LeftRailWidget> createState() => _LeftRailWidgetState();
}

class _LeftRailWidgetState extends ConsumerState<LeftRailWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _widthFactor;

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
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: _widthFactor.value,
                child: child,
              ),
            );
          },
          child: SizedBox(
            width: panelWidth,
            child: Container(
              color: AppColors.surface,
              child: Column(
                children: [
                  _buildHeader(),
                  const Divider(height: 1, color: AppColors.border),
                  // Device Selection — takes up available top space
                  const Expanded(
                    child: DeviceSelectorPanel(isEmbedded: true),
                  ),

                  const Divider(height: 1, color: AppColors.border),

                  // Screenshot + Crop — sizes to its content at the bottom
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ScreenshotSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onCollapse,
            icon: const Icon(Icons.vertical_split, size: 16, color: AppColors.secondaryText),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: AppSpacing.s8),
          Text('ASSETS', style: AppTypography.panelHeader),
        ],
      ),
    );
  }
}

class _ScreenshotSection extends ConsumerWidget {
  Future<void> _pickMedia(WidgetRef ref, BuildContext context, bool isVideo) async {
    final picker = ImagePicker();
    final XFile? file = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(mockupProjectProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SCREENSHOT', style: AppTypography.panelHeader),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: StudioButton(
                  label: 'Image',
                  icon: Icons.image_outlined,
                  variant: ButtonVariant.secondary,
                  onPressed: () => _pickMedia(ref, context, false),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: StudioButton(
                  label: 'Video',
                  icon: Icons.videocam_outlined,
                  variant: ButtonVariant.secondary,
                  onPressed: () => _pickMedia(ref, context, true),
                ),
              ),
            ],
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

