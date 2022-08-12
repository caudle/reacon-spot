import 'package:dirm/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

// ignore: constant_identifier_names
const String THEME = 'theme';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeLoading());

  void onStarted(String? theme) async {
    // get stored theme
    final storedTheme = await _getTheme(theme);
    emit(storedTheme);
  }

  void addTheme({required ThemeData themeData, required String name}) async {
    // store theme
    _setTheme(name);
    emit(ThemeLoaded(themeData: themeData, name: name));
  }
}

// gets theme from storage
Future<ThemeState> _getTheme(String? theme) async {
  switch (theme) {
    case 'light':
      {
        return ThemeLoaded(themeData: AppTheme.lightTheme, name: THEME);
      }
    case 'dark':
      {
        return ThemeLoaded(themeData: AppTheme.darkTheme, name: THEME);
      }
    default:
      return ThemeLoaded(themeData: AppTheme.lightTheme, name: THEME);
  }
}

// sets theme in storage
_setTheme(String theme) async {
  final preferences = await SharedPreferences.getInstance();
  preferences.setString(THEME, theme);
}
