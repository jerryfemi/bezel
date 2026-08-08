import 'package:flutter/material.dart';

enum DeviceCategory {
  ios('iOS'),
  android('Android'),
  tablet('Tablet'),
  macos('macOS'),
  windows('Windows'),
  monitor('Monitor');

  final String label;
  const DeviceCategory(this.label);
}

class DeviceVariant {
  final String id;
  final String colorName;
  final String assetPath;
  // screenRect defines the size of the screen AND the X/Y offset from the top-left of the asset.
  // Example: Rect.fromLTWH(offsetX, offsetY, screenWidth, screenHeight)
  final Rect screenRect;
  final double cornerRadius;

  const DeviceVariant({
    required this.id,
    required this.colorName,
    required this.assetPath,
    required this.screenRect,
    required this.cornerRadius,
  });

  // Polyfill for old code
  String get name => '$colorName Variant';
  String get bezelImagePath => assetPath;
}

class DeviceModel {
  final String id;
  final String name;
  final DeviceCategory category;
  final List<DeviceVariant> variants;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.variants,
  });
}

// Temporary typedef and constant to prevent breaking existing code during migration.
typedef DeviceSpec = DeviceVariant;

class DeviceSpecConstants {
  static const DeviceSpec placeholderIPhone = DeviceVariant(
    id: 'iphone_16_pro_max_desert',
    colorName: 'Desert Titanium',
    assetPath: 'lib/assets/16 Pro Max - Desert Titanium.png',
    screenRect: Rect.fromLTWH(100, 251, 1320, 2717),
    cornerRadius: 144.0,
  );
}
