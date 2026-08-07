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
      id: 'ipad_air_13',
      name: 'iPad Air 13 (M2/M3)',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'ipad_air_13_space_gray',
          colorName: 'Space Gray',
          assetPath: 'lib/assets/iPad Air 13 - M2 & M3 - Landscape - Space Gray.png',
          screenRect: Rect.fromLTWH(64, 64, 1180, 820), 
          cornerRadius: 32.0,
        ),
        DeviceVariant(
          id: 'ipad_air_13_lavender',
          colorName: 'Lavender',
          assetPath: 'lib/assets/iPad Air 13 - M2 & M3  - Landscape - Lavender.png',
          screenRect: Rect.fromLTWH(64, 64, 1180, 820), 
          cornerRadius: 32.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'macbook_pro_16',
      name: 'MacBook Pro 16',
      category: DeviceCategory.macos,
      variants: [
        DeviceVariant(
          id: 'mbp_16_silver',
          colorName: 'Silver',
          assetPath: 'lib/assets/MacBook Pro 16.png',
          screenRect: Rect.fromLTWH(130, 48, 1728, 1117), // Approximate
          cornerRadius: 16.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'xps_16',
      name: 'Dell XPS 16 (2024)',
      category: DeviceCategory.windows,
      variants: [
        DeviceVariant(
          id: 'xps_16_platinum',
          colorName: 'Platinum',
          assetPath: 'lib/assets/2024 XPS 16 Platinum.png',
          screenRect: Rect.fromLTWH(120, 60, 1920, 1200), // Approximate
          cornerRadius: 8.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'surface_laptop_15',
      name: 'Surface Laptop 15',
      category: DeviceCategory.windows,
      variants: [
        DeviceVariant(
          id: 'surface_15_platinum',
          colorName: 'Platinum',
          assetPath: 'lib/assets/Surface Laptop 15 - Platinum.png',
          screenRect: Rect.fromLTWH(100, 80, 1500, 1000), // Approximate
          cornerRadius: 8.0,
        ),
      ],
    ),
  ];
}
