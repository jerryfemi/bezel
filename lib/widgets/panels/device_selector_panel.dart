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

String getCategoryAsset(DeviceCategory cat) {
  switch (cat) {
    case DeviceCategory.ios:
    case DeviceCategory.android:
      return 'lib/assets/iphone.png';
    case DeviceCategory.tablet:
      return 'lib/assets/tablet (2).png';
    case DeviceCategory.macos:
    case DeviceCategory.windows:
      return 'lib/assets/laptop.png';
    case DeviceCategory.monitor:
      return 'lib/assets/imac.png';
  }
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
                  for (final cat in DeviceCategory.values)
                    cat: Tooltip(
                      message: cat.label,
                      child: Opacity(
                        opacity: _selectedCategory == cat ? 1.0 : 0.5,
                        child: Image.asset(
                          getCategoryAsset(cat),
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
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
        Column(
          children: model.variants.map((variant) {
            final isActive = activeDevice.id == variant.id;
            return GestureDetector(
              onTap: () =>
                  ref.read(mockupProjectProvider.notifier).setDevice(variant),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: 2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: AppSpacing.s8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      getCategoryAsset(model.category),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        variant.colorName,
                        style: AppTypography.uiBody.copyWith(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
