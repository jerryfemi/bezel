import 'package:flutter/material.dart';
import '../models/device_spec.dart';

class DeviceRegistry {
  static const List<DeviceModel> devices = [
    // ═══════════════════════════════════════════════════════════════
    // iOS — iPhones
    // ═══════════════════════════════════════════════════════════════
    DeviceModel(
      id: 'iphone_13_mini',
      name: 'iPhone 13 mini',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_13_mini_black',
          colorName: 'Black',
          assetPath: 'lib/assets/13 mini - Black.png',
          screenRect: Rect.fromLTWH(100, 210, 1080, 2230),
          cornerRadius: 100.0,
        ),
        DeviceVariant(
          id: 'iphone_13_mini_blue',
          colorName: 'Blue',
          assetPath: 'lib/assets/13 mini - Blue.png',
          screenRect: Rect.fromLTWH(100, 210, 1080, 2230),
          cornerRadius: 100.0,
        ),
        DeviceVariant(
          id: 'iphone_13_mini_pink',
          colorName: 'Pink',
          assetPath: 'lib/assets/13 mini - Pink.png',
          screenRect: Rect.fromLTWH(100, 210, 1080, 2230),
          cornerRadius: 100.0,
        ),
        DeviceVariant(
          id: 'iphone_13_mini_red',
          colorName: 'Product (RED)',
          assetPath: 'lib/assets/13 mini - Product (RED).png',
          screenRect: Rect.fromLTWH(100, 210, 1080, 2230),
          cornerRadius: 100.0,
        ),
        DeviceVariant(
          id: 'iphone_13_mini_starlight',
          colorName: 'Starlight',
          assetPath: 'lib/assets/13 mini - Starlight.png',
          screenRect: Rect.fromLTWH(100, 210, 1080, 2230),
          cornerRadius: 100.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'iphone_14_pro_max',
      name: 'iPhone 14 Pro Max',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_14_pro_max_deep_purple',
          colorName: 'Deep Purple',
          assetPath: 'lib/assets/14 Pro Max - Deep Purple - Shadow.png',
          screenRect: Rect.fromLTWH(101, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_14_pro_max_gold',
          colorName: 'Gold',
          assetPath: 'lib/assets/14 Pro Max - Gold.png',
          screenRect: Rect.fromLTWH(101, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_14_pro_max_silver',
          colorName: 'Silver',
          assetPath: 'lib/assets/14 Pro Max - Silver.png',
          screenRect: Rect.fromLTWH(101, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_14_pro_max_space_black',
          colorName: 'Space Black',
          assetPath: 'lib/assets/14 Pro Max - Space Black.png',
          screenRect: Rect.fromLTWH(101, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'iphone_15_pro_max',
      name: 'iPhone 15 Pro Max',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_15_pro_max_black_titanium',
          colorName: 'Black Titanium',
          assetPath: 'lib/assets/15 Pro Max - Black Titanium.png',
          screenRect: Rect.fromLTWH(99, 243, 1290, 2653),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_15_pro_max_blue_titanium',
          colorName: 'Blue Titanium',
          assetPath: 'lib/assets/15 Pro Max - Blue Titanium.png',
          screenRect: Rect.fromLTWH(99, 243, 1290, 2653),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_15_pro_max_natural_titanium',
          colorName: 'Natural Titanium',
          assetPath: 'lib/assets/15 Pro Max - Natural Titanium.png',
          screenRect: Rect.fromLTWH(99, 243, 1290, 2653),
          cornerRadius: 130.0,
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
          screenRect: Rect.fromLTWH(100, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_16_plus_pink',
          colorName: 'Pink',
          assetPath: 'lib/assets/16 Plus - Pink.png',
          screenRect: Rect.fromLTWH(100, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_16_plus_teal',
          colorName: 'Teal',
          assetPath: 'lib/assets/16 Plus - Teal.png',
          screenRect: Rect.fromLTWH(100, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_16_plus_ultramarine',
          colorName: 'Ultramarine',
          assetPath: 'lib/assets/16 Plus - Ultramarine.png',
          screenRect: Rect.fromLTWH(100, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_16_plus_white',
          colorName: 'White',
          assetPath: 'lib/assets/16 Plus - White.png',
          screenRect: Rect.fromLTWH(100, 244, 1290, 2652),
          cornerRadius: 130.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'iphone_16_pro_max',
      name: 'iPhone 16 Pro Max',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_16_pro_max_black',
          colorName: 'Black Titanium',
          assetPath: 'lib/assets/16 Pro Max - Black Titanium.png',
          screenRect: Rect.fromLTWH(100, 251, 1320, 2717),
          cornerRadius: 144.0,
        ),
        DeviceVariant(
          id: 'iphone_16_pro_max_desert',
          colorName: 'Desert Titanium',
          assetPath: 'lib/assets/16 Pro Max - Desert Titanium.png',
          screenRect: Rect.fromLTWH(100, 251, 1320, 2717),
          cornerRadius: 144.0,
        ),
        DeviceVariant(
          id: 'iphone_16_pro_max_natural',
          colorName: 'Natural Titanium',
          assetPath: 'lib/assets/16 Pro Max - Natural Titanium.png',
          screenRect: Rect.fromLTWH(100, 251, 1320, 2717),
          cornerRadius: 144.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'iphone_17_pro',
      name: 'iPhone 17 Pro',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_17_pro_cosmic_orange',
          colorName: 'Cosmic Orange',
          assetPath: 'lib/assets/17 Pro - Cosmic Orange.png',
          screenRect: Rect.fromLTWH(100, 250, 1206, 2472),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_17_pro_deep_blue',
          colorName: 'Deep Blue',
          assetPath: 'lib/assets/17 Pro - Deep Blue.png',
          screenRect: Rect.fromLTWH(100, 250, 1206, 2472),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_17_pro_silver',
          colorName: 'Silver',
          assetPath: 'lib/assets/17 Pro - Silver.png',
          screenRect: Rect.fromLTWH(100, 250, 1206, 2472),
          cornerRadius: 130.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'iphone_17_pro_max',
      name: 'iPhone 17 Pro Max',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_17_pro_max_cosmic_orange',
          colorName: 'Cosmic Orange',
          assetPath: 'lib/assets/17 Pro Max - Cosmic Orange.png',
          screenRect: Rect.fromLTWH(100, 254, 1320, 2714),
          cornerRadius: 144.0,
        ),
        DeviceVariant(
          id: 'iphone_17_pro_max_deep_blue',
          colorName: 'Deep Blue',
          assetPath: 'lib/assets/17 Pro Max - Deep Blue.png',
          screenRect: Rect.fromLTWH(100, 254, 1320, 2714),
          cornerRadius: 144.0,
        ),
        DeviceVariant(
          id: 'iphone_17_pro_max_silver',
          colorName: 'Silver',
          assetPath: 'lib/assets/17 Pro Max - Silver.png',
          screenRect: Rect.fromLTWH(100, 254, 1320, 2714),
          cornerRadius: 144.0,
        ),
      ],
    ),
    // Also include the small iPhone 17 Pro asset (lower res)
    DeviceModel(
      id: 'iphone_17_pro_portrait',
      name: 'iPhone 17 Pro (Small)',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_17_pro_portrait_silver',
          colorName: 'Silver',
          assetPath: 'lib/assets/iPhone 17 Pro - Silver - Portrait.png',
          screenRect: Rect.fromLTWH(25, 74, 400, 822),
          cornerRadius: 44.0,
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // iOS — Samsung Galaxy S Air (uses iOS category since it's a phone)
    // Actually these are iPhone Air variants
    // ═══════════════════════════════════════════════════════════════
    DeviceModel(
      id: 'iphone_air',
      name: 'iPhone Air',
      category: DeviceCategory.ios,
      variants: [
        DeviceVariant(
          id: 'iphone_air_cloud_white',
          colorName: 'Cloud White',
          assetPath: 'lib/assets/Air - Cloud White.png',
          screenRect: Rect.fromLTWH(100, 273, 1290, 2623),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_air_light_gold',
          colorName: 'Light Gold',
          assetPath: 'lib/assets/Air - Light Gold.png',
          screenRect: Rect.fromLTWH(100, 273, 1290, 2623),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_air_sky_blue',
          colorName: 'Sky Blue',
          assetPath: 'lib/assets/Air - Sky Blue.png',
          screenRect: Rect.fromLTWH(100, 273, 1290, 2623),
          cornerRadius: 130.0,
        ),
        DeviceVariant(
          id: 'iphone_air_space_black',
          colorName: 'Space Black',
          assetPath: 'lib/assets/Air - Space Black.png',
          screenRect: Rect.fromLTWH(100, 273, 1290, 2623),
          cornerRadius: 130.0,
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // Android
    // ═══════════════════════════════════════════════════════════════
    DeviceModel(
      id: 'pixel_9_pro',
      name: 'Pixel 9 Pro',
      category: DeviceCategory.android,
      variants: [
        DeviceVariant(
          id: 'pixel_9_pro_hazel',
          colorName: 'Hazel',
          assetPath: 'lib/assets/Pixel 9 Pro - Hazel.png',
          screenRect: Rect.fromLTWH(170, 290, 1280, 2708),
          cornerRadius: 126.0,
        ),
        DeviceVariant(
          id: 'pixel_9_pro_rose_quartz',
          colorName: 'Rose Quartz',
          assetPath: 'lib/assets/Pixel 9 Pro - Rose Quartz.png',
          screenRect: Rect.fromLTWH(170, 290, 1280, 2708),
          cornerRadius: 126.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'pixel_9_pro_xl',
      name: 'Pixel 9 Pro XL',
      category: DeviceCategory.android,
      variants: [
        DeviceVariant(
          id: 'pixel_9_pro_xl_hazel',
          colorName: 'Hazel',
          assetPath: 'lib/assets/Pixel 9 Pro XL Hazel.png',
          screenRect: Rect.fromLTWH(170, 286, 1344, 2846),
          cornerRadius: 126.0,
        ),
        DeviceVariant(
          id: 'pixel_9_pro_xl_rose_quartz',
          colorName: 'Rose Quartz',
          assetPath: 'lib/assets/Pixel 9 Pro XL Rose Quartz.png',
          screenRect: Rect.fromLTWH(170, 286, 1344, 2846),
          cornerRadius: 126.0,
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // Tablets
    // ═══════════════════════════════════════════════════════════════
    DeviceModel(
      id: 'ipad_air_10_9_m1',
      name: 'iPad Air 10.9 (M1)',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'ipad_air_10_9_blue',
          colorName: 'Blue',
          assetPath: 'lib/assets/iPad Air - 10.9 - M1 - Landscape - Blue.png',
          screenRect: Rect.fromLTWH(200, 200, 1640, 2360),
          cornerRadius: 72.0,
        ),
        DeviceVariant(
          id: 'ipad_air_10_9_green',
          colorName: 'Green',
          assetPath: 'lib/assets/iPad Air - 10.9 - M1 - Landscape - Green.png',
          screenRect: Rect.fromLTWH(200, 200, 1640, 2360),
          cornerRadius: 72.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'ipad_air_13_m2_m3_landscape',
      name: 'iPad Air 13 (M2/M3) Landscape',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'ipad_air_13_lavender',
          colorName: 'Lavender',
          assetPath: 'lib/assets/iPad Air 13 - M2 & M3  - Landscape - Lavender.png',
          screenRect: Rect.fromLTWH(100, 100, 2732, 2048),
          cornerRadius: 72.0,
        ),
        DeviceVariant(
          id: 'ipad_air_13_space_gray',
          colorName: 'Space Gray',
          assetPath: 'lib/assets/iPad Air 13 - M2 & M3 - Landscape - Space Gray.png',
          screenRect: Rect.fromLTWH(100, 100, 2732, 2048),
          cornerRadius: 72.0,
        ),
        DeviceVariant(
          id: 'ipad_air_13_stardust',
          colorName: 'Stardust',
          assetPath: 'lib/assets/iPad Air 13 - M2 & M3 - Landscape - Stardust.png',
          screenRect: Rect.fromLTWH(100, 100, 2732, 2048),
          cornerRadius: 72.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'ipad_air_13_m2_m3_portrait',
      name: 'iPad Air 13 (M2/M3) Portrait',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'ipad_air_13_portrait_blue',
          colorName: 'Blue',
          assetPath: 'lib/assets/iPad Air 13 M2 & M3 - Portrait - Blue.png',
          screenRect: Rect.fromLTWH(100, 100, 2048, 2732),
          cornerRadius: 72.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'ipad_pro_11_m4',
      name: 'iPad Pro 11 (M4)',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'ipad_pro_11_silver',
          colorName: 'Silver',
          assetPath: 'lib/assets/iPad Pro 11 - M4 - Silver - Landscape.png',
          screenRect: Rect.fromLTWH(56, 54, 1208, 832),
          cornerRadius: 36.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'pixel_tablet',
      name: 'Pixel Tablet',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'pixel_tablet_hazel',
          colorName: 'Hazel',
          assetPath: 'lib/assets/Pixel Tablet - Hazel.png',
          screenRect: Rect.fromLTWH(200, 200, 2747, 1731),
          cornerRadius: 60.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'samsung_galaxy_tab_s11_ultra',
      name: 'Galaxy Tab S11 Ultra',
      category: DeviceCategory.tablet,
      variants: [
        DeviceVariant(
          id: 'galaxy_tab_s11_ultra',
          colorName: 'Graphite',
          assetPath: 'lib/assets/Samsung Galaxy Tab S11 Ultra.png',
          screenRect: Rect.fromLTWH(200, 229, 2960, 1821),
          cornerRadius: 48.0,
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // macOS
    // ═══════════════════════════════════════════════════════════════
    DeviceModel(
      id: 'macbook_air_13',
      name: 'MacBook Air 13',
      category: DeviceCategory.macos,
      variants: [
        DeviceVariant(
          id: 'mba_13',
          colorName: 'Silver',
          assetPath: 'lib/assets/MacBook Air 13.png',
          screenRect: Rect.fromLTWH(350, 306, 2560, 1608),
          cornerRadius: 24.0,
        ),
        DeviceVariant(
          id: 'mba_13_menubar',
          colorName: 'Silver (Menu Bar)',
          assetPath: 'lib/assets/MacBook Air 13 - Menu Bar.png',
          screenRect: Rect.fromLTWH(350, 312, 2560, 1602),
          cornerRadius: 24.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'macbook_air_15',
      name: 'MacBook Air 15',
      category: DeviceCategory.macos,
      variants: [
        DeviceVariant(
          id: 'mba_15',
          colorName: 'Silver',
          assetPath: 'lib/assets/MacBook Air 15.png',
          screenRect: Rect.fromLTWH(350, 306, 2880, 1808),
          cornerRadius: 24.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'macbook_pro_14',
      name: 'MacBook Pro 14',
      category: DeviceCategory.macos,
      variants: [
        DeviceVariant(
          id: 'mbp_14',
          colorName: 'Space Black',
          assetPath: 'lib/assets/MacBook Pro 14.png',
          screenRect: Rect.fromLTWH(462, 365, 3020, 1898),
          cornerRadius: 24.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'macbook_pro_16',
      name: 'MacBook Pro 16',
      category: DeviceCategory.macos,
      variants: [
        DeviceVariant(
          id: 'mbp_16',
          colorName: 'Space Black',
          assetPath: 'lib/assets/MacBook Pro 16.png',
          screenRect: Rect.fromLTWH(443, 378, 3454, 2168),
          cornerRadius: 24.0,
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // Windows
    // ═══════════════════════════════════════════════════════════════
    DeviceModel(
      id: 'xps_13_plus_2023',
      name: 'Dell XPS 13 Plus (2023)',
      category: DeviceCategory.windows,
      variants: [
        DeviceVariant(
          id: 'xps_13_plus_black',
          colorName: 'Black',
          assetPath: 'lib/assets/2023 XPS 13 Plus Black.png',
          screenRect: Rect.fromLTWH(400, 200, 2700, 1686),
          cornerRadius: 16.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'xps_13_oled_2024',
      name: 'Dell XPS 13 OLED (2024)',
      category: DeviceCategory.windows,
      variants: [
        DeviceVariant(
          id: 'xps_13_oled_graphite',
          colorName: 'Graphite',
          assetPath: 'lib/assets/2024 XPS 13 OLED Graphite.png',
          screenRect: Rect.fromLTWH(400, 200, 2700, 1686),
          cornerRadius: 16.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'xps_16_2024',
      name: 'Dell XPS 16 (2024)',
      category: DeviceCategory.windows,
      variants: [
        DeviceVariant(
          id: 'xps_16_platinum',
          colorName: 'Platinum',
          assetPath: 'lib/assets/2024 XPS 16 Platinum.png',
          screenRect: Rect.fromLTWH(463, 200, 3284, 2054),
          cornerRadius: 16.0,
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
          screenRect: Rect.fromLTWH(400, 200, 2496, 1664),
          cornerRadius: 16.0,
        ),
      ],
    ),

    // ═══════════════════════════════════════════════════════════════
    // Monitors
    // ═══════════════════════════════════════════════════════════════
    DeviceModel(
      id: 'apple_studio_display',
      name: 'Apple Studio Display',
      category: DeviceCategory.monitor,
      variants: [
        DeviceVariant(
          id: 'studio_display',
          colorName: 'Silver',
          assetPath: 'lib/assets/Studio Display.png',
          screenRect: Rect.fromLTWH(200, 200, 5120, 2880),
          cornerRadius: 32.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'dell_ultrasharp_5k',
      name: 'Dell UltraSharp 5K 27"',
      category: DeviceCategory.monitor,
      variants: [
        DeviceVariant(
          id: 'dell_ultrasharp_5k',
          colorName: 'Black',
          assetPath: 'lib/assets/Dell UltraSharp 5K Monitor 27.png',
          screenRect: Rect.fromLTWH(300, 1500, 5120, 2880),
          cornerRadius: 0.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'huawei_mateview',
      name: 'Huawei MateView',
      category: DeviceCategory.monitor,
      variants: [
        DeviceVariant(
          id: 'huawei_mateview',
          colorName: 'Silver',
          assetPath: 'lib/assets/Huawei MateView.png',
          screenRect: Rect.fromLTWH(200, 200, 3840, 2560),
          cornerRadius: 0.0,
        ),
      ],
    ),
    DeviceModel(
      id: 'samsung_viewfinity_5k',
      name: 'Samsung ViewFinity S9 5K',
      category: DeviceCategory.monitor,
      variants: [
        DeviceVariant(
          id: 'samsung_viewfinity_5k',
          colorName: 'Black',
          assetPath: 'lib/assets/Samsung S90PC ViewFinity 5K.png',
          screenRect: Rect.fromLTWH(200, 200, 5120, 2880),
          cornerRadius: 0.0,
        ),
      ],
    ),
  ];
}
