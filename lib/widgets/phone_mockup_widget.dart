import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../providers/mockup_provider.dart';

final videoContainerKey = GlobalKey();

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
        child: Stack(
          children: [
            // The media screen layer (bottom layer)
            // so media extends BEHIND the notch/Dynamic Island. The bezel PNG
            // on top naturally masks the notch area, just like a real phone.
            Positioned(
              left: device.screenRect.left - device.screenPadding.left,
              top: device.screenRect.top - device.screenPadding.top,
              width: device.screenRect.width + device.screenPadding.left + device.screenPadding.right,
              height: device.screenRect.height + device.screenPadding.top + device.screenPadding.bottom,
                child: Container(
                  key: videoContainerKey,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(device.cornerRadius),
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

            // The physical device bezel layer on top dictates the size of the Stack
            if (device.assetPath.isNotEmpty)
              IgnorePointer(child: Image.asset(device.assetPath))
            else
              // Fallback for placeholder
              IgnorePointer(
                child: Container(
                  width: device.screenRect.width + device.screenRect.left * 2,
                  height: device.screenRect.height + device.screenRect.top * 2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade800,
                      width: device.screenRect.left,
                    ),
                    borderRadius: BorderRadius.circular(
                      device.cornerRadius + device.screenRect.left,
                    ),
                  ),
                ),
              ),
          ],
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
  late final TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
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
    _transformController.value = Matrix4.identity(); // reset crop on new media

    // Clear the provider when re-initializing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(videoControllerProvider.notifier).state = null;
      if (mounted) ref.read(mockupProjectProvider.notifier).setMediaTransform(Matrix4.identity());
    });

    if (widget.isVideo) {
      if (kIsWeb) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path));
      } else {
        _controller = VideoPlayerController.file(File(widget.path));
      }

      _controller!
          .initialize()
          .then((_) {
            if (mounted) {
              setState(() {});
              _controller!.setVolume(0.0); // Mute video preview
              _controller!.setLooping(true);
              _controller!.addListener(_videoListener);
              _controller!.play();

              // Provide the controller to the rest of the app for export logic
              ref.read(videoControllerProvider.notifier).state = _controller;
            }
          })
          .catchError((error) {
            debugPrint('Video initialization error: $error');
            if (mounted) {
              setState(() {});
            }
          });
    }
  }

  void _videoListener() {
    if (_controller == null || !mounted) return;
    
    // We wrap reading the provider in a try-catch because if the widget is unmounted,
    // reading it could throw an exception, although we check mounted above.
    final project = ref.read(mockupProjectProvider);
    final pos = _controller!.value.position;
    
    final start = project.trimStartTime;
    final end = project.trimEndTime;

    // We add a tiny buffer (50ms) to the end condition to avoid rapid triggering 
    // when exactly at the end time or slightly past it.
    if (end != null && pos >= end) {
      _controller!.seekTo(start ?? Duration.zero);
    } else if (start != null && pos < start) {
      // If we somehow seeked before the start, snap to start
      _controller!.seekTo(start);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _transformController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    
    // Sync external transform if it changes (like on reset)
    if (project.mediaTransform != null && project.mediaTransform != _transformController.value) {
      _transformController.value = project.mediaTransform!;
    }

    Widget mediaContent;
    if (!widget.isVideo) {
      mediaContent = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: kIsWeb
              ? Image.network(widget.path)
              : Image.file(File(widget.path)),
        ),
      );
    } else {
      if (_controller != null && _controller!.value.hasError) {
        mediaContent = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading video:\n${_controller!.value.errorDescription}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      } else if (_controller != null && _controller!.value.isInitialized) {
        mediaContent = SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        );
      } else {
        mediaContent = const Center(child: CircularProgressIndicator());
      }
    }

    final activeTool = ref.watch(activeEditorToolProvider);
    final isCropMode = activeTool == EditorTool.crop;

    return InteractiveViewer(
      transformationController: _transformController,
      panEnabled: isCropMode,
      scaleEnabled: isCropMode,
      minScale: 0.1,
      maxScale: 10.0,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      onInteractionEnd: (details) {
        ref.read(mockupProjectProvider.notifier).setMediaTransform(_transformController.value);
      },
      child: SizedBox.expand(
        child: mediaContent,
      ),
    );
  }
}
