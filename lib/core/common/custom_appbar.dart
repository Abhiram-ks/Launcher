import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String? title;
  final Color? backgroundColor;
  final bool? isTitle;
  final Color? titleColor;
  final List<Widget>? actions;
  const CustomAppBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.titleColor,
    this.isTitle = false,
    this.actions,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppTextStyleNotifier.instance,
        AppFontSizeNotifier.instance,
      ]),
      builder: (context, _) {
        return AppBar(
          centerTitle: true,
          title: isTitle == true
              ? Text(
                  title!,
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle: TextStyle(
                      color: AppTextStyleNotifier.instance.textColor,
                      fontWeight: AppTextStyleNotifier.instance.fontWeight,
                      fontSize: AppFontSizeNotifier.instance.value,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                )
              : null,
          iconTheme: IconThemeData(color: AppTextStyleNotifier.instance.textColor),
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: actions,
        );
      },
    );
  }
}
