import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  /// CHAT APP LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF002DE3), // WhatsApp green
      foregroundColor: Colors.white,
    ),

    primaryColor: const Color(0xFF002DE3),
    hintColor: Colors.grey.shade200,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF002DE3),
      secondary: Color(0xFF25D366),
      surface: Colors.white,
    ),

    textTheme: TextTheme(
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.black87),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.black54),
      bodyMedium: AppTextStyles.buttonText.copyWith(color: Colors.black87),
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.black),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.grey),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF002DE3),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.black87),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF25D366),
      foregroundColor: Colors.white,
    ),
  );

  /// CHAT APP DARK THEME
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1C1B),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF1F2C2B),
      foregroundColor: Colors.white,
    ),

    primaryColor: const Color(0xFF25D366),
    hintColor: const Color(0xFFE5E5E5),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF25D366),
      secondary: Color(0xFF128C7E),
      surface: Color(0xFF1F2C2B),
    ),

    textTheme: TextTheme(
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.white70),
      bodyMedium: AppTextStyles.buttonText.copyWith(color: Colors.white),
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.white),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.white60),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.white),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF1F2C2B),
      filled: true,
      hintStyle: const TextStyle(color: Colors.white54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF25D366),
      foregroundColor: Colors.black,
    ),
  );
}
