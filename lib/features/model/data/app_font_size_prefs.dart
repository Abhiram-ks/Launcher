import 'package:shared_preferences/shared_preferences.dart';
import 'package:minilauncher/core/constant/app_font_sizes.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';

class AppFontSizePrefs {
  AppFontSizePrefs._privateConstructor();

  static final AppFontSizePrefs instance = AppFontSizePrefs._privateConstructor();

  factory AppFontSizePrefs() {
    return instance;
  }

  static const String _sizeKey = 'app_font_size';
  static const double _defaultSize = AppFontSizes.defaultSize;

  Future<void> setSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sizeKey, size);
    AppFontSizeNotifier.instance.updateSize(size);
  }

  Future<double> getSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getDouble(_sizeKey) ?? _defaultSize;
    final normalizedSize = AppFontSizes.normalizeSize(size);
    AppFontSizeNotifier.instance.updateSize(normalizedSize);
    return normalizedSize;
  }

  Future<void> clearSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sizeKey);
    AppFontSizeNotifier.instance.updateSize(_defaultSize);
  }
}

