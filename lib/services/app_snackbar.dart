import 'package:flutter/material.dart';
import '../core/keys/scaffold_messenger_key.dart';
import '../resources/colors.dart';

class AppSnackBar {
  static void showSuccess(String message) {
    _showSnackBar(message, thirdGreen);
  }

  static void showError(String message) {
    _showSnackBar(message, mainRed);
  }

  static void showInfo(String message) {
    _showSnackBar(message, thirdBlue);
  }

  static void _showSnackBar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
