part of 'splash_bloc.dart';

@immutable
abstract class SplashState {}
final class SplashInitial extends SplashState {}
final class GoToLandingScreen extends SplashState {}
final class GoToHomeScreen extends SplashState {}