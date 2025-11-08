import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view/widget/settings_widget/settings_body.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';


class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WallpaperBackground(
        child: Scaffold(
          appBar: CustomAppBar(
            title: "Settings",
            backgroundColor: AppPalette.blackColor,
            isTitle: true,

          ),
          body: bodyPartOfSettings(context: context),
        ),
      ),
    );
  }
}


