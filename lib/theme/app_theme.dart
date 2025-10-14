import 'package:flutter/material.dart';

class AppTheme {
  // Constants
  static const kPrimaryColor = Colors.deepPurple;
  static const kAccentColor = Colors.amber;
  static const kBackgroundColor = Color(0xFF121212);
  static const kSurfaceColor = Color(0xFF1E1E1E);

  static final ThemeData themeData = ThemeData(
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: kBackgroundColor,
    brightness: Brightness.dark,
    cardColor: kSurfaceColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: kAccentColor),
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );
}
