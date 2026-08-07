import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/mockup_provider.dart';

class BackgroundPanel extends ConsumerWidget {
  const BackgroundPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(mockupProjectProvider);

    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Background', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          const Text('Rotation', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSlider(context, 'X Axis', project.rotationX, (val) {
            ref.read(mockupProjectProvider.notifier).setRotation(val, project.rotationY, project.rotationZ);
          }),
          _buildSlider(context, 'Y Axis', project.rotationY, (val) {
            ref.read(mockupProjectProvider.notifier).setRotation(project.rotationX, val, project.rotationZ);
          }),
          _buildSlider(context, 'Z Axis', project.rotationZ, (val) {
            ref.read(mockupProjectProvider.notifier).setRotation(project.rotationX, project.rotationY, val);
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(mockupProjectProvider.notifier).setRotation(0, 0, 0);
            },
            child: const Text('Reset Rotation'),
          )
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context, String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Slider(
          value: value,
          min: -3.14,
          max: 3.14,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
