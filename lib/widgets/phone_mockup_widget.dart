import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../providers/mockup_provider.dart';

class PhoneMockupWidget extends ConsumerWidget {
  const PhoneMockupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(mockupProjectProvider);
    final device = project.device;

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(project.rotationX)
          ..rotateY(project.rotationY)
          ..rotateZ(project.rotationZ),
        alignment: FractionalOffset.center,
        child: Container(
          width: device.screenRect.width + 40, // 20px padding on each side for placeholder bezel
          height: device.screenRect.height + 40,
          decoration: BoxDecoration(
            color: Colors.black, // Placeholder bezel color
            borderRadius: BorderRadius.circular(device.cornerRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, 20),
              )
            ],
            border: Border.all(color: Colors.grey.shade800, width: 2), // Bezel edge
          ),
          child: Center(
            child: Container(
              width: device.screenRect.width,
              height: device.screenRect.height,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(device.cornerRadius - 4), // Inner radius
              ),
              clipBehavior: Clip.antiAlias,
              child: project.sourceImagePath != null
                  ? _MockupMediaWidget(
                      path: project.sourceImagePath!,
                      isVideo: project.isVideo,
                    )
                  : const Center(
                      child: Text(
                        'Select an Image or Video',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MockupMediaWidget extends ConsumerStatefulWidget {
  final String path;
  final bool isVideo;

  const _MockupMediaWidget({required this.path, required this.isVideo});

  @override
  ConsumerState<_MockupMediaWidget> createState() => _MockupMediaWidgetState();
}

class _MockupMediaWidgetState extends ConsumerState<_MockupMediaWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  @override
  void didUpdateWidget(covariant _MockupMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path || oldWidget.isVideo != widget.isVideo) {
      _initMedia();
    }
  }

  void _initMedia() {
    _controller?.dispose();
    _controller = null;
    
    // Clear the provider when re-initializing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(videoControllerProvider.notifier).state = null;
    });

    if (widget.isVideo) {
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path));
      } else {
        _controller = VideoPlayerController.file(File(widget.path));
      }
      
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller!.setVolume(0.0); // Mute video preview
          _controller!.setLooping(true);
          _controller!.play();
          
          // Provide the controller to the rest of the app for export logic
          ref.read(videoControllerProvider.notifier).state = _controller;
        }
      }).catchError((error) {
        debugPrint('Video initialization error: $error');
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We can't guarantee ref is still valid here if the provider is being disposed,
      // but it's good practice to null out if the widget dies but the provider lives.
      try {
         ref.read(videoControllerProvider.notifier).state = null;
      } catch (e) {
        // ignore
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // During overlay capture, render transparent so RepaintBoundary only sees the bezel
    final project = ref.watch(mockupProjectProvider);
    if (project.isCapturingOverlay) {
      return const SizedBox.expand();
    }

    if (!widget.isVideo) {
      return kIsWeb
          ? Image.network(widget.path, fit: BoxFit.cover)
          : Image.file(File(widget.path), fit: BoxFit.cover);
    }

    if (_controller != null) {
      if (_controller!.value.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading video:\n${_controller!.value.errorDescription}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }
      if (_controller!.value.isInitialized) {
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        );
      }
    }

    return const Center(child: CircularProgressIndicator());
  }
}
