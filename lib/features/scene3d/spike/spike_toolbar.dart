import 'package:flutter/material.dart';

import '../device_catalog.dart';
import '../device_profile.dart';
import '../scene_pose.dart';

/// Controls for the 3D test bench. Deliberately plain; the real dock comes in phase 3.
class SpikeToolbar extends StatelessWidget {
  const SpikeToolbar({
    super.key,
    required this.device,
    required this.profile,
    required this.finishId,
    required this.pose,
    required this.error,
    required this.onDevice,
    required this.onFinish,
    required this.onImage,
    required this.onVideo,
  });

  final DeviceEntry device;
  final DeviceProfile? profile;
  final String? finishId;
  final ValueNotifier<ScenePose>? pose;
  final String? error;
  final ValueChanged<DeviceEntry> onDevice;
  final ValueChanged<String> onFinish;
  final VoidCallback onImage;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xE61C1C20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final d in deviceCatalog)
            ChoiceChip(
              label: Text(d.label),
              selected: d.id == device.id,
              onSelected: (_) => onDevice(d),
            ),
          for (final f in profile?.finishes ?? const <DeviceFinish>[])
            _Swatch(finish: f, selected: f.id == finishId, onTap: () => onFinish(f.id)),
          FilledButton.tonal(onPressed: onImage, child: const Text('Screenshot')),
          FilledButton.tonal(onPressed: onVideo, child: const Text('Screen recording')),
          if (pose != null) _PoseReadout(pose: pose!),
          if (error != null) Text(error!, style: const TextStyle(color: Color(0xFFFF8A80))),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.finish, required this.selected, required this.onTap});

  final DeviceFinish finish;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: finish.name,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: finish.body,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : const Color(0x26FFFFFF),
              width: selected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _PoseReadout extends StatelessWidget {
  const _PoseReadout({required this.pose});

  final ValueNotifier<ScenePose> pose;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pose,
      builder: (context, p, _) => Text(
        'turn ${p.turn.toStringAsFixed(0)}°  tilt ${p.tilt.toStringAsFixed(0)}°',
        style: const TextStyle(color: Color(0xFFA1A1A6), fontFeatures: [FontFeature.tabularFigures()]),
      ),
    );
  }
}
