import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';

class CropPanel extends ConsumerWidget {
  const CropPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(mockupProjectProvider);
    final currentScale = project.mediaTransform?.getMaxScaleOnAxis() ?? 1.0;

    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Crop Media', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          const Text('Zoom', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${(currentScale * 100).toInt()}%', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Slider(
                value: currentScale.clamp(0.1, 10.0),
                min: 0.1,
                max: 10.0,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (newScale) {
                  final current = project.mediaTransform?.clone() ?? Matrix4.identity();
                  final scaleRatio = newScale / currentScale;
                  // Scale from the center of the transform
                  current.scale(scaleRatio, scaleRatio, 1.0);
                  ref.read(mockupProjectProvider.notifier).setMediaTransform(current);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(mockupProjectProvider.notifier).setMediaTransform(Matrix4.identity());
            },
            child: const Text('Reset Crop'),
          )
        ],
      ),
    );
  }
}
