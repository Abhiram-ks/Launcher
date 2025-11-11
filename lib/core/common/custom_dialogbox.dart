import 'package:flutter/cupertino.dart';

import '../themes/app_colors.dart';

class CustomCupertinoDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onTap,
    Color? firstButtonColor = AppPalette.redColor,
    required String firstButtonText,
    required String secondButtonText,
  }) {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  firstButtonText,
                  style: TextStyle(color: firstButtonColor),
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                  }
                  onTap(); 
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  secondButtonText,
                  style: TextStyle(),
                ),
              ),
            ],
          ),
    );
  }
}