import 'package:flutter/material.dart';
import 'package:minilauncher/core/utils/app_text_widget.dart';
import 'package:minilauncher/core/utils/text_style_helper.dart';
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
    return AppTextStyleBuilder(
      builder: (context, _) {
        return ListTile(
          leading: Icon(
            icon,
            color: AppTextStyleNotifier.instance.textColor,
          ),
          title: AppText(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: trailing,
          onTap: onTap,
        );
      },
    );
  }
}

