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
import 'package:bezel/services/export/image_export_service.dart';
import 'package:bezel/screens/export_progress_screen.dart';

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

                // Screenshot + Crop + Export — scrollable bottom section
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ScreenshotSection(),
                        const Divider(height: 1, color: AppColors.border),
                        _ExportSection(boundaryKey: boundaryKey),
                      ],
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

class _ExportSection extends ConsumerStatefulWidget {
  final GlobalKey boundaryKey;
  const _ExportSection({required this.boundaryKey});

  @override
  ConsumerState<_ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends ConsumerState<_ExportSection> {
  bool _isExporting = false;

  Future<void> _exportMedia() async {
    setState(() => _isExporting = true);
    final project = ref.read(mockupProjectProvider);

    if (project.isVideo) {
      final rawBytes = ref.read(videoRawBytesProvider);
      if (rawBytes == null || rawBytes.isEmpty) {
        setState(() => _isExporting = false);
        return;
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => ExportProgressScreen(
          boundaryKey: widget.boundaryKey,
          videoRawBytes: rawBytes,
          mockupNotifier: ref.read(mockupProjectProvider.notifier),
          project: project,
        ),
      );
      setState(() => _isExporting = false);
      return;
    }

    // Image Export
    await ImageExportService.exportToPng(widget.boundaryKey);
    if (mounted) setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(mockupProjectProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXPORT', style: AppTypography.panelHeader),
          const SizedBox(height: AppSpacing.s12),
          SizedBox(
            width: double.infinity,
            child: StudioButton(
              label: project.isVideo ? 'Export Video' : 'Export PNG',
              icon: Icons.download_rounded,
              variant: ButtonVariant.primary,
              onPressed: _isExporting ? () {} : _exportMedia,
            ),
          ),
        ],
      ),
    );
  }
}
