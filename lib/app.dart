import 'package:dirm/application/theme/cubit/theme_cubit.dart';
import 'package:dirm/screen/auth/forgot_password/change_password.dart';

import 'package:dirm/screen/auth/login/login.dart';
import 'package:dirm/screen/auth/register/register.dart';
import 'package:dirm/screen/bottom_nav/bottom_nav_bar.dart';
import 'package:dirm/screen/intro/onbording.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class App extends StatefulWidget {
  const App({
    required this.theme,
    required this.initScreen,
    required this.islogged,
    Key? key,
  }) : super(key: key);
  final String? theme;
  final int? initScreen;
  final bool islogged;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    FlutterNativeSplash.remove(); 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => ThemeCubit()..onStarted(widget.theme),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return state is ThemeLoaded
              ? MaterialApp(
                  theme: state.themeData,
                  initialRoute: _getInitialRoute(
                      islogged: widget.islogged, init: widget.initScreen),
                  routes: {
                    // '/splash': (context) => const SplashScreen(),
                    '/onboarding': (context) => const Onboarding(),
                    '/bottom-nav-bar': (context) => const BottomNavBar(),
                    '/login': (context) => const LoginPage(),
                    '/register': (context) => const RegisterPage(),
                    '/forgot-password': (context) => const ChangePassword(),
                  },
                )
              : Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[800]!)),
                );
        },
      ),
    );
  }
}

String _getInitialRoute({required bool islogged, required int? init}) {
  if (islogged) {
    return '/bottom-nav-bar';
  } else {
    if (init == 1) {
      return '/login';
    } else {
      return '/onboarding';
    }
  }
}
