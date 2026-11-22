import 'package:flutter/painting.dart';

/// Bezel's palette: a dark studio where the device is the brightest thing.
abstract final class BezelColors {
  static const canvas = Color(0xFF0E0E11);
  static const surface = Color(0xF21C1C20);
  static const surfaceRaised = Color(0xF71E1E23);
  static const stroke = Color(0x14FFFFFF);
  static const strokeStrong = Color(0x26FFFFFF);
  static const hover = Color(0x0FFFFFFF);
  static const selected = Color(0x21FFFFFF);
  static const dotGrid = Color(0x0FFFFFFF);

  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFFA1A1A6);
  static const textTertiary = Color(0xFF8E8E93);

  static const accent = Color(0xFF2F62E0);
  static const accentLine = Color(0xFF8FB0FF);
  static const accentSoft = Color(0x245A8CFF);
  static const danger = Color(0xFFFF8A80);
}
