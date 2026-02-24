import 'package:flutter/material.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  static bool get isDarkMode => themeMode.value == ThemeMode.dark;
}
