import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => _getLightTheme();
  static ThemeData get darkTheme => _getDarkTheme();

  static ThemeData _getLightTheme() {
    return ThemeData.light();
  }

  static ThemeData _getDarkTheme() {
    return ThemeData.dark();
  }
}
