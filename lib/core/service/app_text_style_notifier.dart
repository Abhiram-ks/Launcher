import 'package:flutter/material.dart';

class AppTextStyleNotifier extends ValueNotifier<Map<String, dynamic>> {
  AppTextStyleNotifier() : super({
    'color': Colors.white60,
    'fontWeight': FontWeight.normal,
    'fontFamily': 'Roboto',
  });

  static final AppTextStyleNotifier instance = AppTextStyleNotifier();

  Color get textColor => value['color'] as Color;
  FontWeight get fontWeight => value['fontWeight'] as FontWeight;
  String get fontFamily => value['fontFamily'] as String;

  void updateTextColor(Color color) {
    value = {
      'color': color,
      'fontWeight': fontWeight,
      'fontFamily': fontFamily,
    };
  }

  void updateFontWeight(FontWeight fontWeight) {
    value = {
      'color': textColor,
      'fontWeight': fontWeight,
      'fontFamily': fontFamily,
    };
  }

  void updateFontFamily(String family) {
    value = {
      'color': textColor,
      'fontWeight': fontWeight,
      'fontFamily': family,
    };
  }

  void updateTextStyle(Color color, FontWeight fontWeight) {
    value = {
      'color': color,
      'fontWeight': fontWeight,
      'fontFamily': fontFamily,
    };
  }

  void updateAll({required Color color, required FontWeight fontWeight, required String fontFamily}) {
    value = {
      'color': color,
      'fontWeight': fontWeight,
      'fontFamily': fontFamily,
    };
  }
}

