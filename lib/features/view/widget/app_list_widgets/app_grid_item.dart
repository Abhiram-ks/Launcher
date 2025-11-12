import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_customization_helper.dart';
import 'package:minilauncher/features/model/data/app_customization_prefs.dart';
import '../app_icon_widget.dart';

class AppGridItem extends StatelessWidget {
  final dynamic app;
  final Function(dynamic app) onTap;
  final Function(dynamic app)? onLongPress;
  final Widget Function(dynamic app)? buildOverlay;

  const AppGridItem({
    super.key,
    required this.app,
    required this.onTap,
    this.onLongPress,
    this.buildOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: AppCustomizationPrefs.instance.watchCustomization(app.packageName),
      builder: (context, customizationSnapshot) {
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
                  onTap: () => onTap(app),
                  onLongPress: onLongPress != null ? () => onLongPress!(app) : null,
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
                          if (buildOverlay != null) buildOverlay!(app),
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
}


