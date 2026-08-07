import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors based on portfolio identity
  static const Color nearBlack = Color(0xFF121212);
  static const Color phosphorTeal = Color(0xFF00FFC4);
  static const Color surfaceColor = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: nearBlack,
      primaryColor: phosphorTeal,
      colorScheme: const ColorScheme.dark(
        primary: phosphorTeal,
        surface: surfaceColor,
        onSurface: Colors.white,
      ),
      fontFamily: 'Space Grotesk', // Make sure to add this to pubspec later if we want it strictly
      appBarTheme: const AppBarTheme(
        backgroundColor: nearBlack,
        elevation: 0,
        centerTitle: false,
      ),
      useMaterial3: true,
    );
  }
}
