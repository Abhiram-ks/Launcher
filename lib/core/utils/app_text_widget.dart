import 'package:flutter/material.dart';
import 'text_style_helper.dart';

/// Reusable text widget that automatically uses app text style
class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final double? letterSpacing;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? fontSizeMultiplier;

  const AppText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSizeMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextStyleBuilder(
      builder: (context, _) {
        final style = fontSizeMultiplier != null
            ? TextStyleHelper.getTextStyleWithMultiplier(
                multiplier: fontSizeMultiplier!,
                fontWeight: fontWeight,
                color: color,
                letterSpacing: letterSpacing,
              )
            : TextStyleHelper.getTextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
                letterSpacing: letterSpacing,
              );

        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

