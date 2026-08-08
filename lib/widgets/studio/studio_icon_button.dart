import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';

class StudioIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final String? tooltip;
  final double size;

  const StudioIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.tooltip,
    this.size = 40.0,
  });

  @override
  State<StudioIconButton> createState() => _StudioIconButtonState();
}

class _StudioIconButtonState extends State<StudioIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isActive
        ? AppColors.accent.withValues(alpha: 0.1)
        : _isHovered
            ? AppColors.raisedSurface
            : Colors.transparent;

    final borderColor = widget.isActive
        ? AppColors.accent.withValues(alpha: 0.3)
        : _isHovered
            ? AppColors.border
            : Colors.transparent;

    final iconColor = widget.isActive
        ? AppColors.accent
        : _isHovered
            ? AppColors.primaryText
            : AppColors.secondaryText;

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.raisedSurface.withValues(alpha: 0.8) : bgColor,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: iconColor,
              size: widget.size * 0.5,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 300),
        child: button,
      );
    }

    return button;
  }
}
