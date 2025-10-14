import 'package:flutter/material.dart';
import 'constants.dart';

final appTheme = ThemeData(
  primarySwatch: kPrimaryColor,
  scaffoldBackgroundColor: kBackgroundColor,
  brightness: Brightness.dark,
  cardColor: kSurfaceColor,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAccentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodySmall: TextStyle(color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kAccentColor,
    foregroundColor: Colors.white,
    elevation: 2,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kSurfaceColor,
    selectedItemColor: kAccentColor,
    unselectedItemColor: Colors.white70,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  useMaterial3: true,
);
