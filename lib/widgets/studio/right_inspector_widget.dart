import 'package:bezel/providers/motion_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import '../panels/background_panel.dart';
import 'preset_selector.dart';
import 'keyframe_editor.dart';
import 'studio_button.dart';
import 'package:bezel/services/export/image_export_service.dart';
import 'package:bezel/screens/export_progress_screen.dart';

/// Visible in both DESIGN and MOTION modes.
/// - DESIGN mode: shows Background / Rotation / Color controls.
/// - MOTION mode: shows Preset Selector + Keyframe Editor.
///
/// Collapsible via a toggle button that hangs off the left edge.
class RightInspectorWidget extends ConsumerStatefulWidget {
  final bool isMotionMode;
  final GlobalKey boundaryKey;

  const RightInspectorWidget({
    super.key,
    required this.isMotionMode,
    required this.boundaryKey,
  });

  @override
  ConsumerState<RightInspectorWidget> createState() =>
      _RightInspectorWidgetState();
}

class _RightInspectorWidgetState extends ConsumerState<RightInspectorWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;

  late final AnimationController _animController;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0, // start expanded
    );
    _widthFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Collapse / Expand toggle
        _buildToggleTab(),

        // Animated panel
        AnimatedBuilder(
          animation: _widthFactor,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: _widthFactor.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: 280,
            color: AppColors.surface,
            child: Column(
              children: [
                Expanded(child: _buildContent()),
                const Divider(height: 1, color: AppColors.border),
                _ExportSection(boundaryKey: widget.boundaryKey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTab() {
    return GestureDetector(
      onTap: _toggle,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 24,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
            border: Border(
              left: BorderSide(color: AppColors.border, width: 1),
              top: BorderSide(color: AppColors.border, width: 1),
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Icon(
            _isExpanded ? Icons.chevron_right : Icons.chevron_left,
            size: 16,
            color: AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isMotionMode) {
      final activeTimeline = ref.watch(activeTimelineProvider);
      final hasPreset = activeTimeline != null;

      return Column(
        children: [
          // Motion Presets (Takes all space if no preset selected)
          Expanded(flex: hasPreset ? 3 : 1, child: PresetSelector()),

          if (hasPreset) ...[
            const Divider(height: 1, color: AppColors.border),
            // Keyframe Editor
            Expanded(flex: 2, child: KeyframeEditor()),
          ],
        ],
      );
    }

    // DESIGN mode: Background / Rotation / Color
    return SingleChildScrollView(child: BackgroundPanel(isEmbedded: true));
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EXPORT', style: AppTypography.panelHeader),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            height: 36, // Slightly reduced height
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
