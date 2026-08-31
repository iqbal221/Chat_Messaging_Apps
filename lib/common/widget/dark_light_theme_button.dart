import 'package:flutter/material.dart';
import 'package:ChatVani/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class DarkLightThemeButton extends StatelessWidget {
  const DarkLightThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return IconButton(
      icon: Icon(
        themeProvider.themeMode == ThemeMode.dark
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
      onPressed: () {
        themeProvider.toggleTheme();
      },
    );
  }
}
