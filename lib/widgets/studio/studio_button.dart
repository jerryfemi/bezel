import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

class StudioButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;

  const StudioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.icon,
  });

  @override
  State<StudioButton> createState() => _StudioButtonState();
}

class _StudioButtonState extends State<StudioButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isPrimary ? AppColors.accent : AppColors.raisedSurface;
    final fgColor = widget.isPrimary ? AppColors.canvas : AppColors.primaryText;
    final borderColor = widget.isPrimary ? AppColors.accent : AppColors.border;

    return MouseRegion(
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: _isPressed 
                ? bgColor.withValues(alpha: 0.8) 
                : _isHovered 
                    ? bgColor.withValues(alpha: widget.isPrimary ? 0.9 : 0.8) 
                    : bgColor,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 16, color: fgColor),
                const SizedBox(width: AppSpacing.s8),
              ],
              Text(
                widget.label,
                style: AppTypography.uiLabel.copyWith(color: fgColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


