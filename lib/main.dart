import 'package:dirm/simple_bloc_observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';

void main() {
  BlocOverrides.runZoned(() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    // preserves splash screen until initialization completes
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    final map = await _initialization();
    // removes splash screen
    //FlutterNativeSplash.remove();
    runApp(App(theme: map['theme'], initScreen: map['initScreen']));
  }, blocObserver: SimpleBlocObserver());
}

Future<Map<String, dynamic>> _initialization() async {
  // initializes firebase api
  await Firebase.initializeApp();
  // gets theme from db
  final preferences = await SharedPreferences.getInstance();
  final theme = preferences.getString("THEME");
  // decides 2 show onboarding
  final int? initScreen = preferences.getInt('initScreen');

  return {'theme': theme, 'initScreen': initScreen};
}
