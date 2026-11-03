import 'package:flutter/material.dart';

class AppThemes {
  static const _navy = Color(0xFF123653);
  static const _turquoise = Color(0xFF1ABC9C); // غيّره للتركواز بتاعك

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _navy,
      brightness: Brightness.light,
      primary: _navy,
      secondary: _turquoise,
    ),
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xFFF4F6F8),
    appBarTheme: const AppBarTheme(
      backgroundColor: _navy,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _navy,
      brightness: Brightness.dark,
      primary: const Color(0xFF5B9BD5),
      secondary: _turquoise,
      surface: const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B2836),
      foregroundColor: Colors.white,
    ),
  );
}