import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/features/view_model/cubit/theme_cubit.dart';

import '../../../../core/common/custom_appbar.dart';
import '../../../../core/constant/constant.dart';
import '../../../../core/themes/app_colors.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ThemeSettingsBody();
  }
}

class _ThemeSettingsBody extends StatelessWidget {
  const _ThemeSettingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Theme Settings',
        isTitle: true,
      ),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppPalette.orengeColor),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThemeModeSection(context, state),
                ConstantWidgets.hight20(context),
                _buildThemeOptionsSection(context, state),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildThemeModeSection(BuildContext context, ThemeState state) {
    return AnimatedBuilder(
      animation: AppTextStyleNotifier.instance,
      builder: (context, _) {
        final textColor = AppTextStyleNotifier.instance.textColor;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: textColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.settings,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                  ConstantWidgets.width20(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme Mode',
                          style: GoogleFonts.getFont(
                            AppTextStyleNotifier.instance.fontFamily,
                            textStyle: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Text(
                          'Toggle between dark and light',
                          style: GoogleFonts.getFont(
                            AppTextStyleNotifier.instance.fontFamily,
                            textStyle: TextStyle(
                              color: textColor.withValues(alpha: 0.6),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: !state.isDarkMode,
                      activeTrackColor: textColor,
                      onChanged: (_) {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionsSection(BuildContext context, ThemeState state) {
    return AnimatedBuilder(
      animation: AppTextStyleNotifier.instance,
      builder: (context, _) {
        final textColor = AppTextStyleNotifier.instance.textColor;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Choose Theme',
                style: GoogleFonts.getFont(
                  AppTextStyleNotifier.instance.fontFamily,
                  textStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            _buildThemeOption(
              context,
              icon: CupertinoIcons.moon_fill,
              title: 'Dark Mode',
              description: 'Dark background with light text',
              isSelected: state.isDarkMode,
              onTap: () {
                context.read<ThemeCubit>().setTheme(AppThemeMode.dark);
              },
              gradient: const [Color(0xFF1A1A2E), Color(0xFF16213E)],
            ),
            ConstantWidgets.hight10(context),
            _buildThemeOption(
              context,
              icon: CupertinoIcons.sun_max_fill,
              title: 'Light Mode',
              description: 'Light background with dark text',
              isSelected: !state.isDarkMode,
              onTap: () {
                context.read<ThemeCubit>().setTheme(AppThemeMode.light);
              },
              gradient: const [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return AnimatedBuilder(
      animation: AppTextStyleNotifier.instance,
      builder: (context, _) {
        final textColor = AppTextStyleNotifier.instance.textColor;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? textColor.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: textColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: title == 'Dark Mode' ? Colors.white : Colors.black87,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          textStyle: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          textStyle: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.checkmark_alt,
                      color: textColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
