import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/app_text_style_notifier.dart';
import '../service/app_font_size_notifier.dart';

/// Helper class for creating consistent text styles throughout the app
class TextStyleHelper {
  /// Get the app's standard text style
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    final notifier = AppTextStyleNotifier.instance;
    final fontSizeNotifier = AppFontSizeNotifier.instance;
    
    return GoogleFonts.getFont(
      notifier.fontFamily,
      textStyle: TextStyle(
        color: color ?? notifier.textColor,
        fontWeight: fontWeight ?? notifier.fontWeight,
        fontSize: fontSize ?? fontSizeNotifier.value,
        letterSpacing: letterSpacing,
      ),
    );
  }

  /// Get text style with custom size multiplier
  static TextStyle getTextStyleWithMultiplier({
    double multiplier = 1.0,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    final fontSize = AppFontSizeNotifier.instance.value * multiplier;
    return getTextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}

/// Widget that rebuilds when text style changes
class AppTextStyleBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, TextStyle textStyle) builder;

  const AppTextStyleBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppTextStyleNotifier.instance,
        AppFontSizeNotifier.instance,
      ]),
      builder: (context, _) {
        final textStyle = TextStyleHelper.getTextStyle();
        return builder(context, textStyle);
      },
    );
  }
}

