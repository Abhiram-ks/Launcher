import 'package:flutter/foundation.dart';
import 'package:minilauncher/core/constant/app_icon_shape.dart';

class AppIconShapeNotifier extends ValueNotifier<AppIconShape> {
  AppIconShapeNotifier() : super(AppIconShape.rectangle);

  static final AppIconShapeNotifier instance = AppIconShapeNotifier();

  void updateShape(AppIconShape shape) {
    value = shape;
  }
}

