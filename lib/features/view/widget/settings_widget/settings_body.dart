import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minilauncher/core/common/custom_launcher.dart';
import 'package:minilauncher/core/service/launcher_service.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/features/model/data/appvalues.dart';
import 'package:minilauncher/features/model/models/app_model.dart';
import 'package:minilauncher/features/view/screens/select_wallpaper/select_wallpaper_screen.dart';
import 'package:minilauncher/features/view/screens/settings_screen/select_shape_screen.dart';
import 'package:minilauncher/features/view/screens/settings_screen/select_text_style_screen.dart';
import '../../../view_model/bloc/image_switch_cubit/image_switch_cubit.dart';
import '../../../view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';
import '../../../view_model/cubit/double_tap_cubit.dart';
import '../../screens/settings_screen/screen_timer_screen.dart';
import '../../../view_model/cubit/all_apps_cubit/all_apps_cubit.dart';
import '../../screens/settings_screen/app_management_screen.dart';
import '../../screens/settings_screen/layout_settings_screen.dart';
import '../../screens/settings_screen/theme_settings_screen.dart';
import 'settings_list_tile.dart';



Widget bodyPartOfSettings({required BuildContext context}) {
  return Column(
    children: [
      SettingsListTile(
        title: "Change Wallpaper",
        icon: CupertinoIcons.photo_on_rectangle,
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
        child: SettingsListTile(
          title: 'Manage Priority Apps',
          icon: CupertinoIcons.checkmark_rectangle_fill,
          onTap: () {
            context.read<RootBloc>().add(EditPriorityAppsEvent());
          },
        ),
      ),
      SettingsListTile(
        title: 'Change Icon Shape',
        icon: CupertinoIcons.square_grid_2x2_fill,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectShapeScreen(),
            ),
          );
        },
      ),
       SettingsListTile(
        title: 'Theme Settings',
        icon: CupertinoIcons.moon_fill,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThemeSettingsScreen(),
            ),
          );
        },
      ),
      SettingsListTile(
        title: 'Style Settings',
        icon: CupertinoIcons.textformat,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SelectTextStyleScreen(),
            ),
          );
        },
      ),
          SettingsListTile(
        title: 'Screen Timer',
        icon: CupertinoIcons.time,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ScreenTimerScreen(),
            ),
          );
        },
      ),
      SettingsListTile(
        title: 'App Management',
        icon: CupertinoIcons.app_badge_fill,
        onTap: () async {
          // Get all apps
          final allApps = AppValues.allApps;
          if (allApps.isNotEmpty) {
            final allAppsModels = allApps.map((app) => AppsModel(app: app)).toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => AllAppsCubit(allAppsModels),
                  child: const AppManagementView(),
                ),
              ),
            );
          }
        },
      ),
      SettingsListTile(
        title: 'Layout Settings',
        icon: Icons.view_carousel_sharp,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LayoutSettingsScreen(),
            ),
          );
        },
      ),
      BlocBuilder<DoubleTapCubit, bool>(
        builder: (context, isEnabled) {
          return SettingsListTile(
            title: 'Double tap turn ${isEnabled ? 'off' : 'on'} screen',
            icon: CupertinoIcons.power,
            trailing: Transform.scale(
              scale: 0.6,
              child: CupertinoSwitch(
                value: isEnabled,
                activeTrackColor: AppTextStyleNotifier.instance.textColor,
                onChanged: (_) {
                  context.read<DoubleTapCubit>().toggle();
                },
              ),
            ),
          );
        },
      ),
      SettingsListTile(
        title: 'Send Feedback',
        icon: CupertinoIcons.bubble_left_bubble_right,
        onTap: () {
          sendFeedback(context);
        },
      ),
      SettingsListTile(
        title: AppValues.isAppDefault ? 'Change default app' : 'Set as default app',
        icon: Icons.settings_accessibility_outlined,
        onTap: () async {
          await LauncherService.setAsDefaultLauncher();
        },
      ),
      SettingsListTile(
        title: 'Terms and Conditions',
        icon: CupertinoIcons.doc_text,
        onTap: () {
          openWebPage(context: context, url: 'https://www.freeprivacypolicy.com/live/e0053561-a7ca-4001-b169-331ba91ee86e', errorMessage: 'Terms and Conditions cannot be opened at the moment due to an error.',);
        },
      ),
      SettingsListTile(
        title: 'Privacy Policy',
        icon: CupertinoIcons.checkmark_shield,
        onTap: () {
          openWebPage(context: context, url: 'https://www.freeprivacypolicy.com/live/2e7d9a61-0733-4688-b5a5-458ce10be82f', errorMessage: 'Privacy Policy cannot be opened at the moment due to an error.',);
        },
      ),
    ],
  );
}

