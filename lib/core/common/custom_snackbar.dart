import 'package:flutter/material.dart';
import 'package:minilauncher/core/themes/app_colors.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    Color textColor = AppPalette.whiteColor,
    Color backgroundColor = Colors.black87,
    int durationSeconds = 2,
    TextAlign textAlign = TextAlign.left,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: 15,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: durationSeconds),
      ),
    );
  }
}