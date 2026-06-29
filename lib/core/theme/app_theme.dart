import 'package:chat_messaging/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// CHAT APP LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F8FA),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF2196F3), // WhatsApp green
      foregroundColor: Colors.white,
    ),

    primaryColor: Color(0xFF2196F3),
    primaryColorLight: const Color(0xFFE3F2FD),
    hintColor: Colors.white,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF25D366),
      surface: Colors.white,
    ),

    textTheme: GoogleFonts.interTextTheme().copyWith(
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.black87),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.black54),
      bodyMedium: AppTextStyles.buttonText.copyWith(color: Colors.black87),
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.black),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.grey),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 20, letterSpacing: 1.2),
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
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2196F3),
      foregroundColor: Colors.white,
    ),
  );

  /// CHAT APP DARK THEME
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1828),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Color(0xFF0F1828),
      foregroundColor: Colors.white,
    ),

    primaryColorDark: const Color(0xFF0F1828),
    primaryColorLight: const Color(0xFF152033),
    hintColor: const Color(0xFFE5E5E5),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF128C7E),
      surface: Color(0xFF1F2C2B),
    ),

    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      titleLarge: AppTextStyles.titleLarge.copyWith(color: Colors.white),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: Colors.white70),
      bodyMedium: AppTextStyles.buttonText.copyWith(color: Colors.white),
      displayLarge: AppTextStyles.displayLarge.copyWith(color: Colors.white),
      displaySmall: AppTextStyles.displaySmall.copyWith(color: Colors.white60),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        textStyle: const TextStyle(fontSize: 20, letterSpacing: 1.2),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 80),
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.white),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF152033),
      filled: true,
      hintStyle: const TextStyle(color: Colors.white54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2196F3),
      foregroundColor: Colors.black,
    ),
  );
}
