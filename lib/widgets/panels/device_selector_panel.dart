import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/device_spec.dart';
import '../../data/device_registry.dart';
import '../../providers/mockup_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../theme/app_typography.dart';
import '../studio/studio_segmented_control.dart';

class DeviceSelectorPanel extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const DeviceSelectorPanel({super.key, this.isEmbedded = false});

  @override
  ConsumerState<DeviceSelectorPanel> createState() =>
      _DeviceSelectorPanelState();
}

class _DeviceSelectorPanelState extends ConsumerState<DeviceSelectorPanel> {
  DeviceCategory _selectedCategory = DeviceCategory.ios;

  @override
  Widget build(BuildContext context) {
    final models = DeviceRegistry.devices
        .where((d) => d.category == _selectedCategory)
        .toList();

    return Container(
      width: widget.isEmbedded ? null : 280,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Panel title
          if (!widget.isEmbedded)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Text('Device', style: AppTypography.headingMedium),
            )
          else
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.s16,
                top: AppSpacing.s16,
                bottom: AppSpacing.s8,
              ),
              child: Text('Device', style: AppTypography.panelHeader),
            ),

          // Category selector — using our custom segmented control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StudioSegmentedControl<DeviceCategory>(
                expand: false, // Prevent wrapping / squishing
                segments: {
                  for (final cat in DeviceCategory.values) cat: cat.label,
                },
                selectedValue: _selectedCategory,
                onValueChanged: (cat) {
                  setState(() => _selectedCategory = cat);
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.s16),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.s8),

          // Device list
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: Text(model.name, style: AppTypography.uiLabel),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            itemCount: model.variants.length,
            itemBuilder: (ctx, i) {
              final variant = model.variants[i];
              final isActive = activeDevice.id == variant.id;

              return GestureDetector(
                onTap: () {
                  ref.read(mockupProjectProvider.notifier).setDevice(variant);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                  width: 120,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.raisedSurface
                        : Colors.transparent,
                    border: Border.all(
                      color: isActive ? AppColors.accent : Colors.transparent,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          child: variant.assetPath.isEmpty
                              ? Icon(
                                  Icons.smartphone,
                                  size: 32,
                                  color: AppColors.secondaryText,
                                )
                              : Image.asset(
                                  variant.assetPath,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.s8,
                          left: AppSpacing.s4,
                          right: AppSpacing.s4,
                        ),
                        child: Text(
                          variant.colorName,
                          style: AppTypography.technicalSubtle.copyWith(
                            fontSize: 10,
                          ),
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
        const SizedBox(height: AppSpacing.s16),
      ],
    );
  }
}
