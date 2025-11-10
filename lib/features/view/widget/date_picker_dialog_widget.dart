import 'package:flutter/material.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';

class DatePickerDialogWidget {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppPalette.blueColor,
              onPrimary: AppPalette.whiteColor,
              surface: AppPalette.blackColor,
              onSurface: AppTextStyleNotifier.instance.textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppPalette.blueColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    return pickedDate;
  }
}

