import 'package:flutter/material.dart';
//show snackbar

void showSnackBar({
  required BuildContext context,
  required String message,
}) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 5),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
