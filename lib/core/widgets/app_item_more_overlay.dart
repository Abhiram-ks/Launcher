import 'package:flutter/material.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';

class AppItemMoreOverlay extends StatelessWidget {
  const AppItemMoreOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.more_horiz,
          size: 12,
          color: AppTextStyleNotifier.instance.textColor,
        ),
      ),
    );
  }
}


