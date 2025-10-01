import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minilauncher/featuresss/presentation/bloc/splash_bloc/splash_bloc.dart';

void splashStateHandle(BuildContext context, SplashState state) {
  if (state is GoToHomeScreen) {
   // Navigator.pushReplacementNamed(context, AppRoutes.login);
  }else if (state is GoToLandingScreen){
    context.go('/dashbord_screen');
  }
}
