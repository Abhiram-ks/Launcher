
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';

class SettingsListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsListTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppTextStyleNotifier.instance,
        AppFontSizeNotifier.instance,
      ]),
      builder: (context, _) {
        final textStyle = GoogleFonts.getFont(
          AppTextStyleNotifier.instance.fontFamily,
          textStyle: TextStyle(
            color: AppTextStyleNotifier.instance.textColor,
            fontWeight: AppTextStyleNotifier.instance.fontWeight,
            fontSize: AppFontSizeNotifier.instance.value,
          ),
        );

        return ListTile(
          leading: Icon(
            icon,
            color:  AppTextStyleNotifier.instance.textColor,
          ),
          title: Text(
            title,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          trailing: trailing,
          onTap: onTap,
        );
      },
    );
  }
}

