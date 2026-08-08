import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mockup_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/app_typography.dart';

class VideoPlaybackControls extends ConsumerStatefulWidget {
  const VideoPlaybackControls({super.key});

  @override
  ConsumerState<VideoPlaybackControls> createState() =>
      _VideoPlaybackControlsState();
}

class _VideoPlaybackControlsState extends ConsumerState<VideoPlaybackControls> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(videoControllerProvider);

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        final position = value.position;
        final duration = value.duration;
        final isPlaying = value.isPlaying;
        final volume = value.volume;
        final isMuted = volume == 0.0;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            // Glass treatment — only used for floating canvas controls
            color: AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(
              color: AppColors.primaryText.withValues(alpha: 0.08),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 32,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause
              GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.primaryText,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              
              // Current time
              Text(
                _formatDuration(position),
                style: AppTypography.technical,
              ),
              const SizedBox(width: AppSpacing.s8),
              
              // Seek slider
              SizedBox(
                width: 200,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.primaryText,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                  ),
                  child: Slider(
                    value: position.inMilliseconds.toDouble().clamp(
                      0.0,
                      duration.inMilliseconds.toDouble(),
                    ),
                    min: 0.0,
                    max: duration.inMilliseconds.toDouble() > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1.0,
                    onChanged: (newPosition) {
                      controller.seekTo(
                        Duration(milliseconds: newPosition.toInt()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              
              // Total time
              Text(
                _formatDuration(duration),
                style: AppTypography.technicalSubtle,
              ),
              const SizedBox(width: AppSpacing.s12),
              
              // Mute toggle
              GestureDetector(
                onTap: () {
                  controller.setVolume(isMuted ? 1.0 : 0.0);
                },
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.secondaryText,
                  size: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
