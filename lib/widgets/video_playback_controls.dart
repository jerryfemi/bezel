import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mockup_provider.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
                onPressed: () {
                  if (isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 200,
                child: Slider(
                  value: position.inMilliseconds.toDouble().clamp(
                    0.0,
                    duration.inMilliseconds.toDouble(),
                  ),
                  min: 0.0,
                  max: duration.inMilliseconds.toDouble() > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1.0,
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Colors.white24,
                  onChanged: (newPosition) {
                    controller.seekTo(
                      Duration(milliseconds: newPosition.toInt()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                color: Colors.white,
                onPressed: () {
                  controller.setVolume(isMuted ? 1.0 : 0.0);
                },
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
