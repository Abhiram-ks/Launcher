import 'package:flutter/material.dart';

class AppTextStyleNotifier extends ValueNotifier<Map<String, dynamic>> {
  AppTextStyleNotifier() : super({
    'color': Colors.white60,
    'fontWeight': FontWeight.normal,
  });

  static final AppTextStyleNotifier instance = AppTextStyleNotifier();

  Color get textColor => value['color'] as Color;
  FontWeight get fontWeight => value['fontWeight'] as FontWeight;

  void updateTextColor(Color color) {
    value = {
      'color': color,
      'fontWeight': fontWeight,
    };
  }

  void updateFontWeight(FontWeight fontWeight) {
    value = {
      'color': textColor,
      'fontWeight': fontWeight,
    };
  }

  void updateTextStyle(Color color, FontWeight fontWeight) {
    value = {
      'color': color,
      'fontWeight': fontWeight,
    };
  }
}

