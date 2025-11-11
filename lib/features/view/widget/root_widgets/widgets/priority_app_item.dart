import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:minilauncher/core/common/custom_snackbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view/widget/app_icon_widget.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';
import 'package:minilauncher/features/view_model/cubit/theme_cubit.dart';

/// Reusable checkbox list item for selecting priority apps
class PriorityAppItem extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final int currentSelectionCount;
  final int maxSelectable;

  const PriorityAppItem({
    super.key,
    required this.app,
    required this.isSelected,
    required this.currentSelectionCount,
    this.maxSelectable = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return ValueListenableBuilder(
          valueListenable: AppFontSizeNotifier.instance,
          builder: (context, ___, ____) {
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _handleToggle(context),
                  title: Row(
                    children: [
                      AppIconWidget(
                        iconData: app.icon,
                        size: 40,
                        appName: app.name,
                      ),
                      ConstantWidgets.width20(context),
                      Flexible(
                        child: Text(
                          app.name,
                          style: GoogleFonts.getFont(
                            AppTextStyleNotifier.instance.fontFamily,
                            textStyle: TextStyle(
                              color: AppTextStyleNotifier.instance.textColor,
                              fontWeight: AppTextStyleNotifier.instance.fontWeight,
                              fontSize: AppFontSizeNotifier.instance.value,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: themeState.isDarkMode
                      ? AppPalette.whiteColor
                      : AppPalette.blackColor,
                  checkColor: themeState.isDarkMode
                      ? AppPalette.blackColor
                      : AppPalette.whiteColor,
                );
              },
            );
          },
        );
      },
    );
  }

  void _handleToggle(BuildContext context) {
    if (!isSelected && currentSelectionCount >= maxSelectable) {
      CustomSnackBar.show(
        context,
        message: 'You can only select up to $maxSelectable apps',
        textAlign: TextAlign.center,
      );
      return;
    }
    
    context.read<RootBloc>().add(
      TogglePriorityAppEvent(app.packageName),
    );
  }
}

