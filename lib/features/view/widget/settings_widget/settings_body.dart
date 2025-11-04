import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/common/custom_launcher.dart';
import 'package:minilauncher/core/service/launcher_service.dart';
import 'package:minilauncher/features/model/data/appvalues.dart';
import 'package:minilauncher/features/view/screens/select_wallpaper/select_wallpaper_screen.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../view_model/bloc/image_switch_cubit/image_switch_cubit.dart';
import '../../../view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';

Widget bodyPartOfSettings({required BuildContext context}) {
  return Column(
    children: [
      ListTile(
        leading: Icon(
          CupertinoIcons.photo_on_rectangle,
          color: AppPalette.whiteColor,
        ),
        title: Text(
          "Change Wallpaper",
          style: TextStyle(color: AppPalette.whiteColor, fontSize: 15),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return BlocProvider(
                  create: (context) {
                    final bloc = context.read<RootBloc>();
                    final initialWallpaper =
                        bloc.currentWallpaper.isNotEmpty
                            ? bloc.currentWallpaper
                            : 'assets/wallpapers/1.jpg';
                    return WallpaperCubit(initialWallpaper);
                  },
                  child: const SelectWallpaperView(),
                );
              },
            ),
          );
        },
      ),
      BlocListener<RootBloc, RootState>(
        listener: (context, state) {
          if (state is SelectPriorityAppState) {
            Navigator.pop(context);
          }
        },
        child: ListTile(
          leading: Icon(
            CupertinoIcons.square_grid_2x2,
            color: AppPalette.whiteColor,
          ),
          title: Text(
            'Manage Priority Apps',
            style: TextStyle(color: AppPalette.whiteColor, fontSize: 15),
          ),
          onTap: () {
            context.read<RootBloc>().add(EditPriorityAppsEvent());
          },
        ),
      ),
      ListTile(
        leading: Icon(
          CupertinoIcons.bubble_left_bubble_right,
          color: AppPalette.whiteColor,
        ),
        title: Text(
          'Send Feedback',
          style: TextStyle(color: AppPalette.whiteColor, fontSize: 15),
        ),
        onTap: () {
          sendFeedback(context);
        },
      ),
      ListTile(
        leading: Icon(
          Icons.settings_accessibility_outlined,
          color: AppPalette.whiteColor,
        ),
        title: Text(
          AppValues.isAppDefault ? 'Change default app' : 'Set as default app',
          style: TextStyle(color: AppPalette.whiteColor, fontSize: 15),
        ),
        onTap: () async {
          await LauncherService.setAsDefaultLauncher();
        },
      ),
      ListTile(
        leading: Icon(CupertinoIcons.doc_text, color: AppPalette.whiteColor),
        title: Text(
          'Terms and Conditions',
          style: TextStyle(color: AppPalette.whiteColor, fontSize: 15),
        ),
        onTap: () {
          openWebPage(context: context, url: 'https://www.freeprivacypolicy.com/live/e0053561-a7ca-4001-b169-331ba91ee86e', errorMessage: 'Terms and Conditions cannot be opened at the moment due to an error.',);
        },
      ),
      ListTile(
        leading: Icon(
          CupertinoIcons.checkmark_shield,
          color: AppPalette.whiteColor,
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(color: AppPalette.whiteColor, fontSize: 15),
        ),
        onTap: () {
          openWebPage(context: context, url: 'https://www.freeprivacypolicy.com/live/2e7d9a61-0733-4688-b5a5-458ce10be82f', errorMessage: 'Privacy Policy cannot be opened at the moment due to an error.',);
        },
      ),
    ],
  );
}

