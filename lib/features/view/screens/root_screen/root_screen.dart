import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';
import 'package:minilauncher/features/view_model/cubit/double_tap_cubit.dart';
import '../../widget/root_widgets/root_widgets.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with DoubleTapHandlerMixin {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoubleTapCubit, bool>(
      builder: (context, isDoubleTapEnabled) {
        return PopScope(
          canPop: false,
          child: GestureDetector(
            onDoubleTap: isDoubleTapEnabled ? handleDoubleTap : null,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: WallpaperBackground(
                child: bodyPartOfRootScreen(context),
              ),
            ),
          ),
        );
      },
    );
  }
}


