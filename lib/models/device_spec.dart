import 'package:flutter/material.dart';

class DeviceSpec {
  final String id;
  final String name;
  final String bezelImagePath;
  final Rect screenRect;
  final double cornerRadius;

  const DeviceSpec({
    required this.id,
    required this.name,
    required this.bezelImagePath,
    required this.screenRect,
    required this.cornerRadius,
  });

  // Placeholder for an iPhone 15 until we have real assets
  static const DeviceSpec placeholderIPhone = DeviceSpec(
    id: 'placeholder_iphone_15',
    name: 'iPhone 15 (Placeholder)',
    bezelImagePath: '', // Empty path means we'll draw a generic box for now
    screenRect: Rect.fromLTWH(20, 20, 393, 852), // Approximate logical pixels
    cornerRadius: 48.0,
  );
}
