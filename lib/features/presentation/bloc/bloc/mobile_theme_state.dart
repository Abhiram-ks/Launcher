part of 'mobile_theme_bloc.dart';

@immutable
sealed class MobileThemeState {}

final class MobileThemeInitial extends MobileThemeState {}

class ThemeLoading extends MobileThemeState {}

class ThemeLoaded extends MobileThemeState {
  final bool isDark;
  ThemeLoaded(this.isDark);
}

class ThemeError extends MobileThemeState {
  final String message;
  ThemeError(this.message);
}