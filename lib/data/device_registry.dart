import 'package:flutter/material.dart';
import '../models/device_spec.dart';

class DeviceRegistry {
  static const List<DeviceModel> devices = [
    DeviceModel(
      id: 'iphone_16_pro_max',
      name: 'iPhone 16 Pro Max',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_16_pro_max_black',
          colorName: 'Black Titanium',
          assetPath: 'lib/assets/16 Pro Max - Black Titanium.png',
          screenRect: Rect.fromLTWH(76, 75, 430, 932), // Needs precise calibration
          cornerRadius: 48.0,
        ),
        DeviceVariant(
          id: 'iphone_16_pro_max_desert',
          colorName: 'Desert Titanium',
          assetPath: 'lib/assets/16 Pro Max - Desert Titanium.png',
          screenRect: Rect.fromLTWH(76, 75, 430, 932),
          cornerRadius: 48.0,
        ),
        DeviceVariant(
          id: 'iphone_16_pro_max_natural',
          colorName: 'Natural Titanium',
          assetPath: 'lib/assets/16 Pro Max - Natural Titanium.png',
          screenRect: Rect.fromLTWH(76, 75, 430, 932),
          cornerRadius: 48.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'iphone_16_plus',
      name: 'iPhone 16 Plus',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_16_plus_black',
          colorName: 'Black',
          assetPath: 'lib/assets/16 Plus - Black.png',
          screenRect: Rect.fromLTWH(78, 77, 430, 932), // Needs precise calibration
          cornerRadius: 48.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'pixel_9_pro',
      name: 'Pixel 9 Pro',
      category: DeviceCategory.android,
      variants: [
        DeviceVariant(
          id: 'pixel_9_pro_hazel',
          colorName: 'Hazel',
          assetPath: 'lib/assets/Pixel 9 Pro - Hazel.png',
          screenRect: Rect.fromLTWH(70, 70, 412, 892), // Needs precise calibration
          cornerRadius: 42.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'ipad_air',
      name: 'iPad Air',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'ipad_air_cloud_white',
          colorName: 'Cloud White',
          assetPath: 'lib/assets/Air - Cloud White.png',
          screenRect: Rect.fromLTWH(80, 80, 820, 1180), // Needs precise calibration
          cornerRadius: 24.0,
        ),
      ],
    ),
  ];
}
