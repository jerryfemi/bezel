import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

enum ButtonVariant { primary, secondary, ghost }

class StudioButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final IconData? icon;

  const StudioButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.secondary,
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
    Color bgColor;
    Color fgColor;
    Color borderColor;

    switch (widget.variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.accent;
        fgColor = Colors.white; // Or dark text if preferred, reference has white text on blue
        borderColor = AppColors.accent;
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.raisedSurface;
        fgColor = AppColors.primaryText;
        borderColor = AppColors.border;
        break;
      case ButtonVariant.ghost:
        bgColor = Colors.transparent;
        fgColor = AppColors.primaryText;
        borderColor = Colors.transparent;
        break;
    }

    // Hover overrides
    if (_isHovered) {
      if (widget.variant == ButtonVariant.ghost) {
        bgColor = AppColors.hoverOverlay;
      } else if (widget.variant == ButtonVariant.secondary) {
        bgColor = AppColors.raisedSurface.withValues(alpha: 0.8);
      } else {
        bgColor = AppColors.accent.withValues(alpha: 0.9);
      }
    }

    if (_isPressed) {
      if (widget.variant == ButtonVariant.ghost) {
        bgColor = AppColors.pressOverlay;
      } else if (widget.variant == ButtonVariant.secondary) {
        bgColor = AppColors.raisedSurface.withValues(alpha: 0.6);
      } else {
        bgColor = AppColors.accent.withValues(alpha: 0.8);
      }
    }

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
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.control),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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


