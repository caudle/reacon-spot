import 'package:dirm/core/colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => _getLightTheme();
  static ThemeData get darkTheme => _getDarkTheme();

  static ThemeData _getLightTheme() {
    return ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        primaryColorLight: primaryLightColor,
        primaryColorDark: primaryDarkColor,
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: secondaryColor),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
        ));
  }

  static ThemeData _getDarkTheme() {
    return ThemeData.dark();
  }
}
