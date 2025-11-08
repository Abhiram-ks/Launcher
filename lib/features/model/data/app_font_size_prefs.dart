import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';
import 'package:minilauncher/core/constant/app_font_sizes.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';

class AppFontSizePrefs {
  AppFontSizePrefs._privateConstructor();

  static final AppFontSizePrefs instance = AppFontSizePrefs._privateConstructor();

  factory AppFontSizePrefs() {
    return instance;
  }

  static const String _sizeKey = StorageKeys.fontSize;
  static const double _defaultSize = AppFontSizes.defaultSize;

  Future<void> setSize(double size) async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(_sizeKey, size);
    AppFontSizeNotifier.instance.updateSize(size);
  }

  Future<double> getSize() async {
    final prefs = HiveStorage.settingsBox;
    final double size = (prefs.get(_sizeKey) as double?) ?? _defaultSize;
    final normalizedSize = AppFontSizes.normalizeSize(size);
    return normalizedSize;
  }

  Future<void> clearSize() async {
    final prefs = HiveStorage.settingsBox;
    await prefs.delete(_sizeKey);
    AppFontSizeNotifier.instance.updateSize(_defaultSize);
  }
}

