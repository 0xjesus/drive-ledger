// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF6C5CE7),
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C5CE7),
        secondary: Color(0xFF00D2D3),
        surface: Color(0xFF252525),
        background: Color(0xFF121212),
        error: Color(0xFFFF7675),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        color: Color(0xFF121212),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(size: 24),
        unselectedIconTheme: IconThemeData(size: 24),
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: Color(0xFF333333),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(),
        bodyMedium: TextStyle(),
        bodySmall: TextStyle(),
        labelLarge: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}