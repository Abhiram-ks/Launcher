import 'package:flutter/material.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';
import '../../widget/root_widgets/root_widgets.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: WallpaperBackground(
          child: bodyPartOfRootScreen(context),
        ),
      ),
    );
  }
}


