import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/constant/app_font_sizes.dart';
import 'package:minilauncher/features/model/data/app_font_size_prefs.dart';
import 'package:minilauncher/features/model/data/app_text_style_prefs.dart';

class TextStyleState {
  final bool isLoading;
  final Color color;
  final FontWeight fontWeight;
  final double fontSize;
  final String fontFamily;

  const TextStyleState({
    required this.isLoading,
    required this.color,
    required this.fontWeight,
    required this.fontSize,
    required this.fontFamily,
  });

  factory TextStyleState.loading() => const TextStyleState(
        isLoading: true,
        color: Colors.white60,
        fontWeight: FontWeight.normal,
        fontSize: AppFontSizes.defaultSize,
        fontFamily: 'Roboto',
      );

  TextStyleState copyWith({
    bool? isLoading,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    String? fontFamily,
  }) {
    return TextStyleState(
      isLoading: isLoading ?? this.isLoading,
      color: color ?? this.color,
      fontWeight: fontWeight ?? this.fontWeight,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class TextStyleCubit extends Cubit<TextStyleState> {
  TextStyleCubit() : super(TextStyleState.loading());

  Future<void> load() async {
    final color = await AppTextStylePrefs().getTextColor();
    final weight = await AppTextStylePrefs().getFontWeight();
    final size = await AppFontSizePrefs().getSize();
    final family = await AppTextStylePrefs().getFontFamily();
    emit(TextStyleState(
      isLoading: false,
      color: color,
      fontWeight: weight,
      fontSize: size,
      fontFamily: family,
    ));
  }

  Future<void> setColor(Color color) async {
    await AppTextStylePrefs().setTextColor(color);
    emit(state.copyWith(color: color));
  }

  Future<void> setFontWeight(FontWeight fontWeight) async {
    await AppTextStylePrefs().setFontWeight(fontWeight);
    emit(state.copyWith(fontWeight: fontWeight));
  }

  Future<void> setFontSize(double fontSize) async {
    await AppFontSizePrefs().setSize(fontSize);
    emit(state.copyWith(fontSize: fontSize));
  }

  Future<void> setFontFamily(String family) async {
    await AppTextStylePrefs().setFontFamily(family);
    emit(state.copyWith(fontFamily: family));
  }
}


