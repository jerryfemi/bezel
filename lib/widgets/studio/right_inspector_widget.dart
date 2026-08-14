import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../panels/background_panel.dart';
import 'preset_selector.dart';
import 'keyframe_editor.dart';

/// Visible in both DESIGN and MOTION modes.
/// - DESIGN mode: shows Background / Rotation / Color controls.
/// - MOTION mode: shows Preset Selector + Keyframe Editor.
///
/// Collapsible via a toggle button that hangs off the left edge.
class RightInspectorWidget extends StatefulWidget {
  final bool isMotionMode;

  const RightInspectorWidget({
    super.key,
    required this.isMotionMode,
  });

  @override
  State<RightInspectorWidget> createState() => _RightInspectorWidgetState();
}

class _RightInspectorWidgetState extends State<RightInspectorWidget>
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
                Expanded(
                  child: _buildContent(),
                ),
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
      return Column(
        children: [
          // Motion Presets
          Expanded(
            flex: 2,
            child: PresetSelector(),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Keyframe Editor
          Expanded(
            flex: 3,
            child: KeyframeEditor(),
          ),
        ],
      );
    }

    // DESIGN mode: Background / Rotation / Color
    return SingleChildScrollView(
      child: BackgroundPanel(isEmbedded: true),
    );
  }
}
