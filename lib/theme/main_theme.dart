import 'package:flutter/material.dart';

final ThemeData recipeAppTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Colors.deepOrange,
    onPrimary: Colors.white,
    secondary: Colors.orange.shade100,
    onSecondary: Colors.white,
    tertiary: const Color(0xFFEF5350),
    onTertiary: Colors.white,
    error: const Color(0xFFB00020),
    onError: Colors.white,
    background: const Color(0xFFFDFDFD),
    onBackground: const Color(0xFF212121),
    surface: const Color(0xFFFFF8F0),
    onSurface: const Color(0xFF212121),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepOrange,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFF212121),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Color(0xFF212121),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF212121),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF66BB6A),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
  ),
);
