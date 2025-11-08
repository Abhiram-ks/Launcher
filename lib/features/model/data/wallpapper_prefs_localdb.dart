import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

class WallpaperPrefs {
  WallpaperPrefs._privateConstructor();

  static final WallpaperPrefs instance = WallpaperPrefs._privateConstructor();

  factory WallpaperPrefs() {
    return instance;
  }

  static const String _wallpaperKey = StorageKeys.selectedWallpaper;
  static const String _defaultWallpaper =  'assets/wallpapers/1.jpg';

  Future<void> setWallpaper(String wallpaperPath) async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(_wallpaperKey, wallpaperPath);
  }

   Future<String> getWallpaper() async {
    final prefs = HiveStorage.settingsBox;
    final String? value = prefs.get(_wallpaperKey) as String?;
    return value ?? _defaultWallpaper;
  }

  Future<void> clearWallpaper() async {
    final prefs = HiveStorage.settingsBox;
    await prefs.delete(_wallpaperKey);
  }
}