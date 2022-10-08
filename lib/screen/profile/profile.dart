import 'package:flutter/material.dart';

import '../../services/storage/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
    );
  }
}

Future<void> _onLogout(BuildContext context) async {
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
}
