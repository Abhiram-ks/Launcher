import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
part 'mobile_theme_event.dart';
part 'mobile_theme_state.dart';

class MobileThemeBloc extends Bloc<MobileThemeEvent, MobileThemeState> {
  static const _channel = MethodChannel("com.minilaunch/theme");

  MobileThemeBloc() : super(MobileThemeInitial()) {
    on<LoadCurrentTheme>(_onLoadCurrentTheme);
    on<SetDarkTheme>(_onSetDarkTheme);
    on<SetLightTheme>(_onSetLightTheme);
    add(LoadCurrentTheme());
  }

  Future<void> _onLoadCurrentTheme(
      LoadCurrentTheme event, Emitter<MobileThemeState> emit) async {
    emit(ThemeLoading());
    try {
      final isDark =
          await _channel.invokeMethod<bool>("getCurrentMode") ?? false;
      emit(ThemeLoaded(isDark));
    } catch (e, stack) {
      log("❌ LoadCurrentTheme error: $e", stackTrace: stack);
      emit(ThemeError("LoadCurrentTheme error: $e"));
    }
  }

  Future<void> _onSetDarkTheme(
      SetDarkTheme event, Emitter<MobileThemeState> emit) async {
    try {
      await _channel.invokeMethod("setDarkMode");
      add(LoadCurrentTheme()); // refresh state
    } catch (e, stack) {
      log("❌ SetDarkTheme error: $e", stackTrace: stack);
      emit(ThemeError("SetDarkTheme error: $e"));
    }
  }

  Future<void> _onSetLightTheme(
      SetLightTheme event, Emitter<MobileThemeState> emit) async {
    try {
      await _channel.invokeMethod("setLightMode");
      add(LoadCurrentTheme()); // refresh state
    } catch (e, stack) {
      log("❌ SetLightTheme error: $e", stackTrace: stack);
      emit(ThemeError("SetLightTheme error: $e"));
    }
  }
}
