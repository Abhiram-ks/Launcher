import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: AppTextStyleNotifier.instance.textColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.getFont(
            AppTextStyleNotifier.instance.fontFamily,
            color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.6),
          ),
          filled: true,
          fillColor: Colors.white10,
          prefixIcon: Icon(
            Icons.search,
            color: AppTextStyleNotifier.instance.textColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}


