
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/constant/storage_keys.dart';
import 'package:minilauncher/core/service/hive_storage.dart';

enum AppThemeMode { dark, light }

class ThemeState  {
  final AppThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    required this.themeMode,
    this.isLoading = false,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: AppThemeMode.dark,
      isLoading: true,
    );
  }

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isDarkMode => themeMode == AppThemeMode.dark;
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final themeString = HiveStorage.settingsBox.get(
        StorageKeys.themeMode,
        defaultValue: 'dark',
      ) as String;

      emit(state.copyWith(
        themeMode: themeString == 'light' ? AppThemeMode.light : AppThemeMode.dark,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await HiveStorage.settingsBox.put(
      StorageKeys.themeMode,
      newTheme == AppThemeMode.dark ? 'dark' : 'light',
    );
    emit(state.copyWith(themeMode: newTheme));
  }

  Future<void> setTheme(AppThemeMode themeMode) async {
    await HiveStorage.settingsBox.put(
      StorageKeys.themeMode,
      themeMode == AppThemeMode.dark ? 'dark' : 'light',
    );
    emit(state.copyWith(themeMode: themeMode));
  }

  static AppThemeMode getThemeMode() {
    final themeString = HiveStorage.settingsBox.get(
      StorageKeys.themeMode,
      defaultValue: 'dark',
    ) as String;
    return themeString == 'light' ? AppThemeMode.light : AppThemeMode.dark;
  }
}

