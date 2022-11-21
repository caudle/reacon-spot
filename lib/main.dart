import 'dart:async';

import 'package:dirm/services/storage/database_service.dart';

import 'package:flutter/material.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // preserves splash screen until initialization completes
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final map = await _getInitialData();
  runApp(
    App(
      theme: map['theme'],
      initScreen: map['initScreen'],
      islogged: map['islogged'],
    ),
  );
}

Future<Map<String, dynamic>> _getInitialData() async {
  // gets theme from db
  final preferences = await SharedPreferences.getInstance();
  final theme = preferences.getString("THEME");
  // decides 2 show onboarding
  final int? initScreen = preferences.getInt('initScreen');
  // check user auth state
  final db = DatabaseService();
  final islogged = await db.isLoggedIn();

  return {
    'theme': theme,
    'initScreen': initScreen,
    'islogged': islogged,
  };
}
