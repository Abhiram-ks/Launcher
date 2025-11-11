part of 'mobile_theme_bloc.dart';

@immutable
sealed class MobileThemeEvent {}

class LoadCurrentTheme extends MobileThemeEvent {}

class SetDarkTheme extends MobileThemeEvent {}

class SetLightTheme extends MobileThemeEvent {}
