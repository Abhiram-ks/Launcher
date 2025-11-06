import 'package:flutter/material.dart';

class AppFontWeights {
  // Note: FontWeight.normal == FontWeight.w400, FontWeight.bold == FontWeight.w700
  // So we only include unique values
  static const List<FontWeight> availableWeights = [
    FontWeight.w100,
    FontWeight.w400,  // This is also FontWeight.normal
    FontWeight.w500,
    FontWeight.w700,  // This is also FontWeight.bold
    FontWeight.w800,
    FontWeight.w900,
  ];

  static const List<String> weightNames = [
    '100 (Thin)',
    '400 (Normal/Regular)',
    '500 (Medium)',
    '700 (Bold)',
    '800 (Extra Bold)',
    '900 (Black)',
  ];

  static String getWeightName(FontWeight weight) {
    // Map normal to w400 and bold to w700 for display
    FontWeight displayWeight = weight;
    if (weight == FontWeight.normal) {
      displayWeight = FontWeight.w400;
    } else if (weight == FontWeight.bold) {
      displayWeight = FontWeight.w700;
    }
    
    final index = availableWeights.indexOf(displayWeight);
    if (index == -1) return '400 (Normal/Regular)';
    return weightNames[index];
  }

  // Convert any FontWeight to one of our available weights
  static FontWeight normalizeWeight(FontWeight weight) {
    if (weight == FontWeight.normal) {
      return FontWeight.w400;
    } else if (weight == FontWeight.bold) {
      return FontWeight.w700;
    }
    // If it's already in our list, return it
    if (availableWeights.contains(weight)) {
      return weight;
    }
    // Otherwise, find the closest match
    return FontWeight.w400; // Default
  }
}

