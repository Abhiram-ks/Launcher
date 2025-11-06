import 'package:shared_preferences/shared_preferences.dart';
import 'package:minilauncher/core/constant/app_icon_shape.dart';
import 'package:minilauncher/core/service/app_icon_shape_notifier.dart';

class AppIconShapePrefs {
  AppIconShapePrefs._privateConstructor();

  static final AppIconShapePrefs instance = AppIconShapePrefs._privateConstructor();

  factory AppIconShapePrefs() {
    return instance;
  }

  static const String _shapeKey = 'app_icon_shape';
  static const AppIconShape _defaultShape = AppIconShape.rectangle;

  Future<void> setShape(AppIconShape shape) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shapeKey, shape.name);
    // Notify listeners immediately
    AppIconShapeNotifier.instance.updateShape(shape);
  }

  Future<AppIconShape> getShape() async {
    final prefs = await SharedPreferences.getInstance();
    final shapeName = prefs.getString(_shapeKey);
    if (shapeName == null) {
      AppIconShapeNotifier.instance.updateShape(_defaultShape);
      return _defaultShape;
    }
    
    try {
      final shape = AppIconShape.values.firstWhere(
        (shape) => shape.name == shapeName,
        orElse: () => _defaultShape,
      );
      AppIconShapeNotifier.instance.updateShape(shape);
      return shape;
    } catch (e) {
      AppIconShapeNotifier.instance.updateShape(_defaultShape);
      return _defaultShape;
    }
  }

  Future<void> clearShape() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shapeKey);
    AppIconShapeNotifier.instance.updateShape(_defaultShape);
  }
}

