
import 'core/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/view/screens/root_screen/root_screen.dart';
import 'features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';


void main(){
  runApp(const MyApp());
}


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
        routes: {'/': (context) => const RootScreen()},
      ),
    );
  }
}

