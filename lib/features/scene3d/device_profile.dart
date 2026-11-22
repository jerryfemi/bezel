import 'package:flutter/painting.dart';

/// What a prepared device offers. Mirrors web/devices/<id>/profile.json.
class DeviceProfile {
  const DeviceProfile({
    required this.id,
    required this.name,
    required this.screenAspect,
    required this.finishes,
    required this.defaultFinish,
  });

  factory DeviceProfile.fromJson(Map<String, dynamic> json) {
    final screens = (json['screens'] as List).cast<Map<String, dynamic>>();
    return DeviceProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      screenAspect: (screens.first['aspect'] as num).toDouble(),
      finishes: (json['finishes'] as List)
          .map((f) => DeviceFinish.fromJson(f as Map<String, dynamic>))
          .toList(),
      defaultFinish: json['defaultFinish'] as String,
    );
  }

  final String id;
  final String name;
  final double screenAspect;
  final List<DeviceFinish> finishes;
  final String defaultFinish;
}

class DeviceFinish {
  const DeviceFinish({required this.id, required this.name, required this.body});

  factory DeviceFinish.fromJson(Map<String, dynamic> json) => DeviceFinish(
        id: json['id'] as String,
        name: json['name'] as String,
        body: _hex(json['body'] as String),
      );

  final String id;
  final String name;
  final Color body;

  static Color _hex(String hex) =>
      Color(int.parse(hex.replaceFirst('#', ''), radix: 16) | 0xFF000000);
}
