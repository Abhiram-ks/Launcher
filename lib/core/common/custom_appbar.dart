import 'package:flutter/material.dart';
import 'package:minilauncher/core/utils/app_text_widget.dart';
import 'package:minilauncher/core/utils/text_style_helper.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';

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
    return AppTextStyleBuilder(
      builder: (context, _) {
        return AppBar(
          centerTitle: true,
          title: isTitle == true && title != null
              ? AppText(
                  title!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
