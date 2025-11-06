import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minilauncher/core/constant/app_font_weights.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';

class AppTextStylePrefs {
  AppTextStylePrefs._privateConstructor();

  static final AppTextStylePrefs instance = AppTextStylePrefs._privateConstructor();

  factory AppTextStylePrefs() {
    return instance;
  }

  static const String _colorKey = 'app_text_color';
  static const String _fontWeightKey = 'app_text_font_weight';
  
  // Default values
  static const Color _defaultColor = Colors.white60;
  static const FontWeight _defaultFontWeight = FontWeight.normal;

  Future<void> setTextColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    // Calculate ARGB32 value from color components to avoid deprecated .value
    final argb32 = ((color.a * 255).round() << 24) |
                    ((color.r * 255).round() << 16) |
                    ((color.g * 255).round() << 8) |
                    (color.b * 255).round();
    await prefs.setInt(_colorKey, argb32);
    AppTextStyleNotifier.instance.updateTextColor(color);
  }

  Future<Color> getTextColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_colorKey);
    final color = colorValue == null ? _defaultColor : Color(colorValue);
    AppTextStyleNotifier.instance.updateTextColor(color);
    return color;
  }

  Future<void> setFontWeight(FontWeight fontWeight) async {
    final prefs = await SharedPreferences.getInstance();
    // Store the weight value (100, 400, 500, etc.)
    await prefs.setInt(_fontWeightKey, fontWeight.value);
    AppTextStyleNotifier.instance.updateFontWeight(fontWeight);
  }

  Future<FontWeight> getFontWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final fontWeightValue = prefs.getInt(_fontWeightKey);
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
    AppTextStyleNotifier.instance.updateFontWeight(fontWeight);
    return fontWeight;
  }

  Future<void> clearTextStyle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_colorKey);
    await prefs.remove(_fontWeightKey);
    AppTextStyleNotifier.instance.updateTextStyle(_defaultColor, _defaultFontWeight);
  }
}

