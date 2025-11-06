import 'package:flutter/material.dart';
import 'package:minilauncher/core/constant/app_font_sizes.dart';

class AppFontSizeNotifier extends ValueNotifier<double> {
  AppFontSizeNotifier() : super(AppFontSizes.defaultSize);

  static final AppFontSizeNotifier instance = AppFontSizeNotifier();

  void updateSize(double size) {
    value = size;
  }
}

