import 'package:flutter/material.dart';
import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';
import 'package:minilauncher/core/constant/app_font_weights.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';

class AppTextStylePrefs {
  AppTextStylePrefs._privateConstructor();

  static final AppTextStylePrefs instance = AppTextStylePrefs._privateConstructor();

  factory AppTextStylePrefs() {
    return instance;
  }

  static const String _colorKey = StorageKeys.textColor;
  static const String _fontWeightKey = StorageKeys.textFontWeight;
  
  // Default values
  static const Color _defaultColor = Colors.white60;
  static const FontWeight _defaultFontWeight = FontWeight.normal;
  static const String _defaultFontFamily = 'Roboto';

  Future<void> setTextColor(Color color) async {
    final prefs = HiveStorage.settingsBox;
    // Calculate ARGB32 value from color components to avoid deprecated .value
    final argb32 = ((color.a * 255).round() << 24) |
                    ((color.r * 255).round() << 16) |
                    ((color.g * 255).round() << 8) |
                    (color.b * 255).round();
    await prefs.put(_colorKey, argb32);
    AppTextStyleNotifier.instance.updateTextColor(color);
  }

  Future<Color> getTextColor() async {
    final prefs = HiveStorage.settingsBox;
    final int? colorValue = prefs.get(_colorKey) as int?;
    final color = colorValue == null ? _defaultColor : Color(colorValue);
    return color;
  }

  Future<void> setFontWeight(FontWeight fontWeight) async {
    final prefs = HiveStorage.settingsBox;
    // Store the weight value (100, 400, 500, etc.)
    await prefs.put(_fontWeightKey, fontWeight.value);
    AppTextStyleNotifier.instance.updateFontWeight(fontWeight);
  }

  Future<FontWeight> getFontWeight() async {
    final prefs = HiveStorage.settingsBox;
    final int? fontWeightValue = prefs.get(_fontWeightKey) as int?;
    FontWeight fontWeight = _defaultFontWeight;
    
    if (fontWeightValue != null) {
      // Find matching FontWeight from available weights
      try {
        // Try to find exact match first
        fontWeight = AppFontWeights.availableWeights.firstWhere(
          (w) => w.value == fontWeightValue,
          orElse: () {
            // If not found, create FontWeight from value and normalize it
            final tempWeight = FontWeight.values.firstWhere(
              (w) => w.value == fontWeightValue,
              orElse: () => _defaultFontWeight,
            );
            return AppFontWeights.normalizeWeight(tempWeight);
          },
        );
      } catch (e) {
        fontWeight = _defaultFontWeight;
      }
    }
    return fontWeight;
  }

  Future<void> clearTextStyle() async {
    final prefs = HiveStorage.settingsBox;
    await prefs.delete(_colorKey);
    await prefs.delete(_fontWeightKey);
    AppTextStyleNotifier.instance.updateTextStyle(_defaultColor, _defaultFontWeight);
  }

  Future<void> setFontFamily(String family) async {
    final prefs = HiveStorage.settingsBox;
    await prefs.put(StorageKeys.textFontFamily, family);
    AppTextStyleNotifier.instance.updateFontFamily(family);
  }

  Future<String> getFontFamily() async {
    final prefs = HiveStorage.settingsBox;
    final String? fam = prefs.get(StorageKeys.textFontFamily) as String?;
    return fam ?? _defaultFontFamily;
  }
}

