import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color secondaryGrey = Color(0xFFE0E0E0);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryBlack,
      secondary: Colors.black,
      surface: backgroundWhite,
      onSurface: primaryBlack,
    ),
    scaffoldBackgroundColor: backgroundWhite,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundWhite,
      foregroundColor: primaryBlack,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryBlack,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlack,
        foregroundColor: backgroundWhite,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryBlack,
      unselectedItemColor: Colors.grey,
      backgroundColor: backgroundWhite,
      elevation: 0,
    ),
  );
}
