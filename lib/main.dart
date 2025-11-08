import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Hive initialized via HiveStorage
import 'package:minilauncher/features/model/data/app_font_size_prefs.dart';
import 'package:minilauncher/features/model/data/app_text_style_prefs.dart';
import 'core/service/app_font_size_notifier.dart';
import 'core/service/app_icon_shape_notifier.dart';
import 'core/service/app_text_style_notifier.dart';
import 'core/service/hive_storage.dart';
import 'core/themes/app_themes.dart';
import 'features/model/data/app_icon_shape_prefs.dart';
import 'features/view/screens/root_screen/root_screen.dart';
import 'features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';
import 'features/view_model/cubit/double_tap_cubit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await HiveStorage.init();
  
  // Set system UI overlay style for better appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Preload settings values
  final preloadedShape = await AppIconShapePrefs().getShape();
  final preloadedColor = await AppTextStylePrefs().getTextColor();
  final preloadedWeight = await AppTextStylePrefs().getFontWeight();
  final preloadedFontSize = await AppFontSizePrefs().getSize();
  final preloadedFontFamily = await AppTextStylePrefs().getFontFamily();

  runApp(const MyApp());

  // Update notifiers after first frame to avoid setState during build
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AppIconShapeNotifier.instance.updateShape(preloadedShape);
    AppTextStyleNotifier.instance.updateAll(color: preloadedColor, fontWeight: preloadedWeight, fontFamily: preloadedFontFamily);
    AppFontSizeNotifier.instance.updateSize(preloadedFontSize);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RootBloc()..add(RootInitialEvent())),
        BlocProvider(create: (_) => DoubleTapCubit()),
      ],
      child: MaterialApp(
        title: 'Mini Launcher',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const RootScreen(),
      ),
    );
  }
}
