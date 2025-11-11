import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';

/// Reusable header widget for priority app selection screen
class PriorityAppHeader extends StatelessWidget {
  final int selectedCount;

  const PriorityAppHeader({
    super.key,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.06,
        bottom: 15,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'Select Priority Apps ($selectedCount)',
          style: GoogleFonts.getFont(
            AppTextStyleNotifier.instance.fontFamily,
            textStyle: TextStyle(
              color: AppTextStyleNotifier.instance.textColor,
              fontWeight: AppTextStyleNotifier.instance.fontWeight,
              fontSize: AppFontSizeNotifier.instance.value,
            ),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }
}

