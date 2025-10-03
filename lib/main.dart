import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/themes/app_themes.dart';
import 'package:minilauncher/features/view/screens/root_screen.dart';
import 'package:minilauncher/features/view_model/bloc/bloc/root_bloc_dart_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RootBloc()..add(RootInitialEvent()),
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          '/': (context) => const RootScreen(),
        },
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}