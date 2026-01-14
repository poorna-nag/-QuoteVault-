import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData greenLightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static ThemeData greenDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );

  static List<ThemeData> get themes => [greenLightTheme, greenDarkTheme];
  static List<String> get themeNames => ['Light', 'Dark'];
}
