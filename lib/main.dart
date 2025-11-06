import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/features/model/data/app_font_size_prefs.dart';
import 'package:minilauncher/features/model/data/app_text_style_prefs.dart';
import 'core/themes/app_themes.dart';
import 'features/model/data/app_icon_shape_prefs.dart';
import 'features/view/screens/root_screen/root_screen.dart';
import 'features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for better appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize icon shape preference
  await AppIconShapePrefs().getShape();
  await AppTextStylePrefs().getTextColor();
  await AppTextStylePrefs().getFontWeight();
  await AppFontSizePrefs().getSize();
  await AppIconShapePrefs().getShape();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RootBloc()..add(RootInitialEvent()),
      child: MaterialApp(
        title: 'Mini Launcher',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const RootScreen(),
      ),
    );
  }
}
