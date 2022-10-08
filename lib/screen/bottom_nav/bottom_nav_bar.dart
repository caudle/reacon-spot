import 'dart:async';
import 'dart:convert';

import 'package:dirm/screen/add/add.dart';
import 'package:dirm/screen/fav/fav.dart';
import 'package:dirm/screen/home/home.dart';
import 'package:dirm/screen/profile/profile.dart';
import 'package:dirm/screen/search/search.dart';
import 'package:dirm/services/api/rest_api.dart';
import 'package:dirm/services/storage/database_service.dart';
import 'package:dirm/util/shared.dart';
import 'package:flutter/material.dart';

import '../../modal/listing.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with AutomaticKeepAliveClientMixin {
  int selectedIndex = 0;
  late PageController _pageController;
  static const List<Widget> pages = [
    HomePage(),
    FavPage(),
    AddPage(),
    SearchPage(),
    ProfilePage(),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _pageController = PageController(initialPage: selectedIndex);
    super.initState();
  }

  // change btm bar index
  void changeIndex(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.jumpToPage(selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), label: "favourites"),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "add"),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: "search"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: "profile"),
          ],
          currentIndex: selectedIndex,
          onTap: changeIndex,
          //showSelectedLabels: false,
          //showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}



/*Future<void> _onLogout(BuildContext context) async {
  try {
    // delete user frm db
    final databaseService = DatabaseService();
    await databaseService.deleteUser();
    // delete token
    await databaseService.deleteToken();
  } catch (e) {
    // snackbar
    SnackBar snackBar = SnackBar(
      content: Text('log out failed: ${e.toString()}'),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}*/

