import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/device_spec.dart';
import '../../data/device_registry.dart';
import '../../providers/mockup_provider.dart';

class DeviceSelectorPanel extends ConsumerStatefulWidget {
  const DeviceSelectorPanel({super.key});

  @override
  ConsumerState<DeviceSelectorPanel> createState() => _DeviceSelectorPanelState();
}

class _DeviceSelectorPanelState extends ConsumerState<DeviceSelectorPanel> {
  DeviceCategory _selectedCategory = DeviceCategory.ios;

  @override
  Widget build(BuildContext context) {
    final models = DeviceRegistry.devices.where((d) => d.category == _selectedCategory).toList();

    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Device', style: Theme.of(context).textTheme.titleLarge),
          ),
          // Category tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: DeviceCategory.values.map((cat) {
                final isActive = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat.label),
                    selected: isActive,
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: models.length,
              itemBuilder: (ctx, index) {
                return _DeviceModelItem(model: models[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceModelItem extends ConsumerWidget {
  final DeviceModel model;
  const _DeviceModelItem({required this.model});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDevice = ref.watch(mockupProjectProvider).device;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            model.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: model.variants.length,
            itemBuilder: (ctx, i) {
              final variant = model.variants[i];
              final isActive = activeDevice.id == variant.id;
              
              return GestureDetector(
                onTap: () {
                  ref.read(mockupProjectProvider.notifier).setDevice(variant);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 120,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white10 : Colors.transparent,
                    border: Border.all(
                      color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: variant.assetPath.isEmpty 
                              ? const Icon(Icons.smartphone, size: 32)
                              : Image.asset(variant.assetPath, fit: BoxFit.contain),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
                        child: Text(
                          variant.colorName,
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
