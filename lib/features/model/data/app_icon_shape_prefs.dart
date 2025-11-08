import 'package:minilauncher/core/constant/app_icon_shape.dart';
import 'package:minilauncher/core/service/app_icon_shape_notifier.dart';
import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

class AppIconShapePrefs {
  AppIconShapePrefs._privateConstructor();

  static final AppIconShapePrefs instance = AppIconShapePrefs._privateConstructor();

  factory AppIconShapePrefs() {
    return instance;
  }

  static const String _shapeKey = StorageKeys.iconShape;
  static const AppIconShape _defaultShape = AppIconShape.rectangle;

  Future<void> setShape(AppIconShape shape) async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(_shapeKey, shape.name);
    // Notify listeners immediately
    AppIconShapeNotifier.instance.updateShape(shape);
  }

  Future<AppIconShape> getShape() async {
    final prefs = HiveStorage.settingsBox;
    final String? shapeName = prefs.get(_shapeKey) as String?;
    if (shapeName == null) {
      return _defaultShape;
    }
    
    try {
      final shape = AppIconShape.values.firstWhere(
        (shape) => shape.name == shapeName,
        orElse: () => _defaultShape,
      );
      return shape;
    } catch (e) {
      return _defaultShape;
    }
  }

  Future<void> clearShape() async {
    final prefs = HiveStorage.settingsBox;
    await prefs.delete(_shapeKey);
    AppIconShapeNotifier.instance.updateShape(_defaultShape);
  }
}

