import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_customization_helper.dart';
import 'package:minilauncher/features/model/data/app_customization_prefs.dart';
import 'package:minilauncher/features/view_model/cubit/all_apps_cubit/all_apps_state.dart';
import '../app_icon_widget.dart';

/// Reusable grouped apps list widget
/// Can be used for different purposes by providing different onTap callbacks
Widget buildGroupedAppsList({
  required AllAppsState state,
  required ScrollController scrollController,
  required Map<String, GlobalKey> sectionKeys,
  required Function(dynamic app) onAppTap,
  Widget Function(dynamic app)? trailing,
}) {
  return ListView.builder(
    controller: scrollController,
    padding: const EdgeInsets.only(right: 30),
    itemCount: state.availableLetters.length,
    itemBuilder: (context, index) {
      final letter = state.availableLetters[index];
      final apps = state.groupedApps[letter]!;

      return Column(
        key: sectionKeys[letter],
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              letter,
              style: GoogleFonts.getFont(
                AppTextStyleNotifier.instance.fontFamily,
                color: AppTextStyleNotifier.instance.textColor.withValues(
                  alpha: .7,
                ),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ),
          // Apps in this section
          ...apps.map((appModel) {
            final app = appModel.app;
            return StreamBuilder<Map<String, dynamic>?>(
              stream: AppCustomizationPrefs.instance.watchCustomization(app.packageName),
              builder: (context, customizationSnapshot) {
                // Get customized name and icon
                final displayName = AppCustomizationHelper.getCustomizedAppName(
                  app.packageName,
                  app.name,
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
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          leading: AppIconWidget(
                            iconData: app.icon,
                            iconPath: customIconPath,
                            size: 40,
                            appName: displayName,
                          ),
                          title: Text(
                            displayName,
                            style: GoogleFonts.getFont(
                              AppTextStyleNotifier.instance.fontFamily,
                              textStyle: TextStyle(
                                color: AppTextStyleNotifier.instance.textColor,
                                fontWeight: AppTextStyleNotifier.instance.fontWeight,
                                fontSize: AppFontSizeNotifier.instance.value,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: trailing?.call(app),
                          onTap: () => onAppTap(app),
                        );
                      },
                    );
                  },
                );
              },
            );
          }),
          ConstantWidgets.hight20(context),
        ],
      );
    },
  );
}

