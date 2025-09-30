
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppPalette.primaryColor,
    scaffoldBackgroundColor: AppPalette.blackColor,
    fontFamily: GoogleFonts.poppins().fontFamily,

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppPalette.blackColor,
      selectedItemColor: AppPalette.orengeColor,
      unselectedItemColor: AppPalette.greyColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.blackColor,
      iconTheme: IconThemeData(color: AppPalette.whiteColor),
      titleTextStyle: TextStyle(
        color: AppPalette.whiteColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppPalette.whiteColor),
      bodyMedium: TextStyle(color: AppPalette.whiteColor),
      bodySmall: TextStyle(color: AppPalette.whiteColor),
    ),

    iconTheme: const IconThemeData(color: AppPalette.whiteColor),
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppPalette.primaryColor,
    scaffoldBackgroundColor: AppPalette.whiteColor,
    fontFamily: GoogleFonts.poppins().fontFamily,

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppPalette.whiteColor,
      selectedItemColor: AppPalette.blueColor,
      unselectedItemColor: AppPalette.greyColor,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.whiteColor,
      iconTheme: IconThemeData(color: AppPalette.blackColor),
      titleTextStyle: TextStyle(
        color: AppPalette.blackColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppPalette.blackColor),
      bodyMedium: TextStyle(color: AppPalette.blackColor),
      bodySmall: TextStyle(color: AppPalette.blackColor),
    ),

    iconTheme: const IconThemeData(color: AppPalette.blackColor),
  );
}