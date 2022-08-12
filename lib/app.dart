import 'package:dirm/application/theme/cubit/theme_cubit.dart';

import 'package:dirm/screen/auth/login/login.dart';
import 'package:dirm/screen/auth/register/phone_verification.dart';
import 'package:dirm/screen/auth/register/register.dart';
import 'package:dirm/screen/bottom_nav/bottom_nav_bar.dart';
import 'package:dirm/screen/intro/onbording.dart';
import 'package:dirm/services/firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class App extends StatefulWidget {
  const App({required this.theme, required this.initScreen, Key? key})
      : super(key: key);
  final String? theme;
  final int? initScreen;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
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
              ? StreamBuilder<User?>(
                  stream: _auth.userChanges(),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? MaterialApp(
                            theme: state.themeData,
                            initialRoute: _getInitialRoute(
                                user: snapshot.data, init: widget.initScreen),
                            routes: {
                              // '/splash': (context) => const SplashScreen(),
                              '/onboarding': (context) => const Onboarding(),
                              '/bottom-nav-bar': (context) =>
                                  const BottomNavBar(),
                              '/login': (context) => const LoginPage(),
                              '/register': (context) => const RegisterPage(),
                              '/register/phone-verification': (context) =>
                                  const PhoneVerificationPage(),
                            },
                            debugShowCheckedModeBanner: false,
                          )
                        : Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue[800]!)),
                          );
                  })
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

String _getInitialRoute({required User? user, required int? init}) {
  if (user != null) {
    return '/bottom-nav-bar';
  } else {
    if (init == 1) {
      return '/login';
    } else {
      return '/onboarding';
    }
  }
}
