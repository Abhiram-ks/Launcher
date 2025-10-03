import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
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
          appBar: AppBar(
            forceMaterialTransparency: true,
            elevation: 0,
            title: Text('Settings', style: TextStyle(color: AppPalette.whiteColor, fontSize: 14, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(onPressed: () => Navigator.of(context).pop()
            , icon: Icon(CupertinoIcons.left_chevron)),
          ),
        ),
      ),
    );
  }
}