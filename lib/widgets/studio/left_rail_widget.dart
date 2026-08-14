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

class LeftRailWidget extends ConsumerWidget {
  final GlobalKey boundaryKey;

  const LeftRailWidget({
    super.key,
    required this.boundaryKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adapt width based on available space
        final panelWidth = constraints.maxWidth > 0
            ? constraints.maxWidth.clamp(220.0, 300.0)
            : 260.0;

        return SizedBox(
          width: panelWidth,
          child: Container(
            color: AppColors.surface,
            child: Column(
              children: [
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
        );
      },
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

