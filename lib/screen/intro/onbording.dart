import 'dart:async';

import 'package:dirm/screen/intro/widgets/slide.dart';
import 'package:dirm/screen/intro/widgets/slide_dots.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 3) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(_currentPage,
            duration: const Duration(milliseconds: 450), curve: Curves.easeIn);
      }
    });
    _setInitScreen();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    timer?.cancel();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _setInitScreen() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setInt('initScreen', 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: 3,
            itemBuilder: (context, index) => Slide(index: index),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 25),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int i = 0; i < 3; i++)
                        if (i == _currentPage)
                          const SlideDots(true)
                        else
                          const SlideDots(false)
                    ],
                  ),
                  const SizedBox(
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        child: const Text(
                          'skip',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0),
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
