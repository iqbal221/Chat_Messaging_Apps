import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  /// Theme Mode
  ThemeMode themeMode = ThemeMode.dark;

  void toggleTheme() {
    if (themeMode == ThemeMode.dark) {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.dark;
    }

    notifyListeners();
  }
}
