import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_customization_helper.dart';
import 'package:minilauncher/features/model/data/app_customization_prefs.dart';
import 'package:minilauncher/features/view_model/cubit/all_apps_cubit/all_apps_state.dart';
import '../app_icon_widget.dart';

/// Reusable grid view for grouped apps
Widget buildGroupedAppsGrid({
  required AllAppsState state,
  required ScrollController scrollController,
  required int columnCount,
  required Function(dynamic app) onAppTap,
  Function(dynamic app)? onAppLongPress,
  Widget Function(dynamic app)? buildGridItemOverlay,
}) {
  return GridView.builder(
    controller: scrollController,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columnCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
    ),
    itemCount: state.availableLetters.fold<int>(
      0,
      (sum, letter) => sum + (state.groupedApps[letter]?.length ?? 0),
    ),
    itemBuilder: (context, index) {
      // Find the app at this index
      int currentIndex = 0;
      for (final letter in state.availableLetters) {
        final apps = state.groupedApps[letter] ?? [];
        if (currentIndex + apps.length > index) {
          final appIndex = index - currentIndex;
          final appModel = apps[appIndex];
          return _buildGridAppItem(
            appModel.app,
            onAppTap,
            onAppLongPress,
            buildGridItemOverlay,
          );
        }
        currentIndex += apps.length;
      }
      return const SizedBox.shrink();
    },
  );
}

/// Reusable grid view for filtered apps
Widget buildFilteredAppsGrid({
  required AllAppsState state,
  required int columnCount,
  required Function(dynamic app) onAppTap,
  Function(dynamic app)? onAppLongPress,
  Widget Function(dynamic app)? buildGridItemOverlay,
}) {
  return GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columnCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
    ),
    itemCount: state.filteredApps.length,
    itemBuilder: (context, index) {
      final app = state.filteredApps[index].app;
      return _buildGridAppItem(
        app,
        onAppTap,
        onAppLongPress,
        buildGridItemOverlay,
      );
    },
  );
}

// Grid Item Widget
Widget _buildGridAppItem(
  dynamic app,
  Function(dynamic app) onAppTap,
  Function(dynamic app)? onAppLongPress,
  Widget Function(dynamic app)? buildGridItemOverlay,
) {
  return StreamBuilder<Map<String, dynamic>?>(
    stream: AppCustomizationPrefs.instance.watchCustomization(app.packageName),
    builder: (context, customizationSnapshot) {
      // Get customized name and icon
      final displayName = AppCustomizationHelper.getCustomizedAppName(
        app.packageName,
        app.name ?? '',
      );
      final customIconPath = AppCustomizationHelper.getCustomizedAppIconPath(
        app.packageName,
      );

      return ValueListenableBuilder(
        valueListenable: AppTextStyleNotifier.instance,
        builder: (context, _, __) {
          return ValueListenableBuilder(
            valueListenable: AppFontSizeNotifier.instance,
            builder: (context, ___, ____) {
              return InkWell(
                onTap: () => onAppTap(app),
                onLongPress: onAppLongPress != null ? () => onAppLongPress(app) : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        AppIconWidget(
                          iconData: app.icon,
                          iconPath: customIconPath,
                          size: 42,
                          appName: displayName,
                        ),
                        if (buildGridItemOverlay != null)
                          buildGridItemOverlay(app),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        displayName,
                        style: GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          textStyle: TextStyle(
                            color: AppTextStyleNotifier.instance.textColor,
                            fontWeight: AppTextStyleNotifier.instance.fontWeight,
                            fontSize: AppFontSizeNotifier.instance.value * 0.75,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

