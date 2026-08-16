import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/motion_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import 'studio_button.dart';

class TimelinePanel extends ConsumerStatefulWidget {
  const TimelinePanel({super.key});

  @override
  ConsumerState<TimelinePanel> createState() => _TimelinePanelState();
}

class _TimelinePanelState extends ConsumerState<TimelinePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Default duration; will update based on timeline
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _controller.addListener(() {
      ref.read(currentPlaybackTimeProvider.notifier).state =
          _controller.lastElapsedDuration ??
          (_controller.duration! * _controller.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      if (_controller.isCompleted) {
        _controller.forward(from: 0);
      } else {
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sequence = ref.watch(activeSequenceProvider);
    final currentTime = ref.watch(currentPlaybackTimeProvider);

    final totalDuration = sequence.totalDuration == Duration.zero
        ? const Duration(seconds: 5)
        : sequence.totalDuration;

    if (_controller.duration != totalDuration) {
      _controller.duration = totalDuration;
    }

    final progress = totalDuration.inMilliseconds == 0
        ? 0.0
        : currentTime.inMilliseconds / totalDuration.inMilliseconds;

    return Container(
      height: 48, // Fixed height
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Solid dark grey, no cheap blur
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Custom Play Button Block
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 56,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.accent,
              ),
              child: Center(
                child: Icon(
                  _controller.isAnimating
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          // Scrubber
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                activeTrackColor: Colors.white.withValues(alpha: 0.8),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 6.0,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 14.0,
                ),
                trackShape: const RoundedRectSliderTrackShape(), // clean edges
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  if (_controller.isAnimating) {
                    _controller.stop();
                  }
                  final newTime = Duration(
                    milliseconds: (value * totalDuration.inMilliseconds)
                        .round(),
                  );
                  _controller.value = value;
                  ref.read(currentPlaybackTimeProvider.notifier).state =
                      newTime;
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          // Timestamp
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              '${_formatDuration(currentTime)} / ${_formatDuration(totalDuration)}',
              style: AppTypography.uiLabel.copyWith(
                fontFamily:
                    'Inter', // Ensure standard font, but add tabular figures
                fontFeatures: const [FontFeature.tabularFigures()],
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11, // Tiny and precise
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    String twoDigitMillis = twoDigits(d.inMilliseconds.remainder(1000) ~/ 10);
    return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitMillis";
  }
}
