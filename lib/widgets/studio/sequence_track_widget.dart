import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/motion_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';

/// Interlocking chevron-shaped sequence track with live progress fills.
class SequenceTrackWidget extends ConsumerStatefulWidget {
  const SequenceTrackWidget({super.key});

  @override
  ConsumerState<SequenceTrackWidget> createState() =>
      _SequenceTrackWidgetState();
}

class _SequenceTrackWidgetState extends ConsumerState<SequenceTrackWidget> {
  int? _editingDurationIndex;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController();
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  void _openDurationEditor(int index, double currentSeconds) {
    setState(() {
      _editingDurationIndex = index;
      _durationController.text = currentSeconds.toStringAsFixed(1);
    });
  }

  void _closeDurationEditor() {
    setState(() {
      _editingDurationIndex = null;
    });
  }

  void _applyDuration(int index, double newSeconds) {
    final sequence = ref.read(activeSequenceProvider);
    if (index >= sequence.blocks.length) return;

    final clamped = newSeconds.clamp(0.1, 10.0);
    final block = sequence.blocks[index];
    final newTimeline = block.timeline.withScaledDuration(
      Duration(milliseconds: (clamped * 1000).round()),
    );
    final newBlock = block.copyWith(timeline: newTimeline);
    ref.read(activeSequenceProvider.notifier).state =
        sequence.withUpdatedBlock(index, newBlock);

    _durationController.text = clamped.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final sequence = ref.watch(activeSequenceProvider);
    final activeIndex = ref.watch(activeBlockIndexProvider);
    final currentTime = ref.watch(currentPlaybackTimeProvider);

    if (sequence.blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate accumulated start times for each block
    final List<Duration> blockStartTimes = [];
    Duration accumulated = Duration.zero;
    for (final block in sequence.blocks) {
      blockStartTimes.add(accumulated);
      accumulated += block.timeline.duration;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chevron track
        SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: 4,
            ),
            child: Row(
              children: List.generate(sequence.blocks.length, (i) {
                final block = sequence.blocks[i];
                final blockDuration = block.timeline.duration;
                final blockStart = blockStartTimes[i];
                final blockEnd = blockStart + blockDuration;
                final isActive = i == activeIndex;

                // Calculate fill progress for this block
                double fillProgress = 0.0;
                if (currentTime >= blockEnd) {
                  fillProgress = 1.0; // Fully complete
                } else if (currentTime > blockStart) {
                  final elapsed = currentTime - blockStart;
                  fillProgress = blockDuration.inMicroseconds > 0
                      ? (elapsed.inMicroseconds /
                              blockDuration.inMicroseconds)
                          .clamp(0.0, 1.0)
                      : 0.0;
                }

                final isPlaying = fillProgress > 0.0 && fillProgress < 1.0;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(activeBlockIndexProvider.notifier).state = i;
                      if (_editingDurationIndex == i) {
                        _closeDurationEditor();
                      } else {
                        _openDurationEditor(
                          i,
                          blockDuration.inMilliseconds / 1000.0,
                        );
                      }
                    },
                    child: ClipPath(
                      clipper: _ChevronClipper(
                        isFirst: i == 0,
                        isLast: i == sequence.blocks.length - 1,
                      ),
                      child: Stack(
                        children: [
                          // Base (inactive background)
                          Container(
                            color: isActive
                                ? AppColors.raisedSurface
                                : const Color(0xFF252525),
                          ),
                          // Progress fill gradient
                          if (fillProgress > 0.0)
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: fillProgress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00D4AA),
                                      AppColors.accent,
                                      const Color(0xFFAB47BC),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // Label + progress text
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  block.name,
                                  style: AppTypography.uiLabel.copyWith(
                                    color: fillProgress > 0.3
                                        ? Colors.white
                                        : isActive
                                            ? AppColors.primaryText
                                            : AppColors.secondaryText,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 11,
                                  ),
                                ),
                                if (isPlaying) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(fillProgress * 100).round()}%',
                                    style: AppTypography.uiLabel.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Active border highlight
                          if (isActive)
                            Positioned.fill(
                              child: ClipPath(
                                clipper: _ChevronClipper(
                                  isFirst: i == 0,
                                  isLast: i == sequence.blocks.length - 1,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.accent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Delete button (top-right, only when active)
                          if (isActive)
                            Positioned(
                              right: i == sequence.blocks.length - 1 ? 4 : 14,
                              top: 2,
                              child: GestureDetector(
                                onTap: () {
                                  final newSeq =
                                      sequence.withRemovedBlock(i);
                                  ref
                                      .read(
                                          activeSequenceProvider.notifier)
                                      .state = newSeq;
                                  if (activeIndex >= newSeq.blocks.length) {
                                    ref
                                        .read(activeBlockIndexProvider
                                            .notifier)
                                        .state = (newSeq.blocks.length - 1)
                                        .clamp(0, 999);
                                  }
                                  _closeDurationEditor();
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // Inline duration editor (visible when a block is tapped)
        if (_editingDurationIndex != null &&
            _editingDurationIndex! < sequence.blocks.length)
          _buildInlineDurationEditor(sequence),
      ],
    );
  }

  Widget _buildInlineDurationEditor(dynamic sequence) {
    final index = _editingDurationIndex!;
    final block = sequence.blocks[index];
    final currentSeconds = block.timeline.duration.inMilliseconds / 1000.0;

    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${block.name} duration',
            style: AppTypography.uiLabel.copyWith(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          // Down arrow
          _buildArrowButton(
            icon: Icons.keyboard_arrow_down,
            onTap: () => _applyDuration(index, currentSeconds - 0.1),
          ),
          const SizedBox(width: 4),
          // Editable seconds field
          SizedBox(
            width: 48,
            height: 24,
            child: TextField(
              controller: _durationController,
              style: AppTypography.uiLabel.copyWith(
                color: AppColors.primaryText,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                filled: true,
                fillColor: AppColors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
              onSubmitted: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) {
                  _applyDuration(index, parsed);
                }
              },
            ),
          ),
          const SizedBox(width: 2),
          Text(
            's',
            style: AppTypography.uiLabel.copyWith(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          // Up arrow
          _buildArrowButton(
            icon: Icons.keyboard_arrow_up,
            onTap: () => _applyDuration(index, currentSeconds + 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.raisedSurface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: AppColors.secondaryText),
      ),
    );
  }
}

/// Clips a rectangle into a chevron/arrow shape.
/// [isFirst] gives a flat left edge, [isLast] gives a flat right edge.
class _ChevronClipper extends CustomClipper<Path> {
  final bool isFirst;
  final bool isLast;

  _ChevronClipper({this.isFirst = false, this.isLast = false});

  @override
  Path getClip(Size size) {
    const double notchDepth = 10.0;
    final path = Path();

    // Start at top-left
    path.moveTo(0, 0);

    // Top edge
    path.lineTo(isLast ? size.width : size.width - notchDepth, 0);

    // Right notch (arrow point)
    if (!isLast) {
      path.lineTo(size.width, size.height / 2);
      path.lineTo(size.width - notchDepth, size.height);
    } else {
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    }

    // Bottom edge
    path.lineTo(0, size.height);

    // Left notch (indentation from previous arrow)
    if (!isFirst) {
      path.lineTo(notchDepth, size.height / 2);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(_ChevronClipper oldClipper) =>
      isFirst != oldClipper.isFirst || isLast != oldClipper.isLast;
}
