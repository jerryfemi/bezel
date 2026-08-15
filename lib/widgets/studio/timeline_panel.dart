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

    final totalDuration = sequence.totalDuration == Duration.zero ? const Duration(seconds: 5) : sequence.totalDuration;

    if (_controller.duration != totalDuration) {
      _controller.duration = totalDuration;
    }

    final progress = totalDuration.inMilliseconds == 0
        ? 0.0
        : currentTime.inMilliseconds / totalDuration.inMilliseconds;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s32),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.raisedSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      width: 400,
      child: Row(
        children: [
          StudioButton(
            label: '',
            icon: _controller.isAnimating ? Icons.pause : Icons.play_arrow,
            onPressed: _togglePlayPause,
            variant: ButtonVariant.primary,
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primaryText,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  if (_controller.isAnimating) {
                    _controller.stop();
                  }
                  final newTime = Duration(
                    milliseconds: (value * totalDuration.inMilliseconds).round(),
                  );
                  _controller.value = value;
                  ref.read(currentPlaybackTimeProvider.notifier).state = newTime;
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Text(
            '${_formatDuration(currentTime)} / ${_formatDuration(totalDuration)}',
            style: AppTypography.uiLabel.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: AppColors.secondaryText,
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
