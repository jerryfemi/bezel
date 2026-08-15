import 'package:flutter/material.dart';

class AppColors {
  // Base Palette
  static const Color canvas = Color(0xFF121212);     // Very dark grey/black for canvas
  static const Color surface = Color(0xFF1E1E1E);    // Panel background
  static const Color raisedSurface = Color(0xFF2C2C2C); // Buttons/Hover elements
  static const Color border = Color(0xFF383838);     // Subtle dividers
  
  // Typography
  static const Color primaryText = Color(0xFFFFFFFF); // Crisp white
  static const Color secondaryText = Color(0xFF8A8D93); // Muted grey
  
  // Accents & Semantics
  static const Color accent = Color(0xFF5A8CFF); // Vibrant blue
  static const Color danger = Color(0xFFFF5A5A); // Bright red
  
  // Interactive States
  static const Color hoverOverlay = Color(0x14FFFFFF);
  static const Color pressOverlay = Color(0x24FFFFFF);
}
