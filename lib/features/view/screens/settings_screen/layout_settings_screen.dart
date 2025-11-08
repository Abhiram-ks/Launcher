import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/constant/app_layout_type.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/features/view_model/cubit/layout_cubit.dart';

import '../../../../core/themes/app_colors.dart';
import 'select_text_style_screen.dart';

class LayoutSettingsScreen extends StatelessWidget {
  const LayoutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LayoutSettingsBody();
  }
}

class _LayoutSettingsBody extends StatelessWidget {
  const _LayoutSettingsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Layout Settings',
        backgroundColor: AppPalette.blackColor,
        isTitle: true,
      ),
      body: BlocBuilder<LayoutCubit, LayoutState>(
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
                _buildPreviewSection(context, state),
                ConstantWidgets.hight20(context),
                _buildLayoutTypeSection(context, state),
                ConstantWidgets.hight20(context),
                if (state.layoutType == AppLayoutType.grid)
                  _buildGridColumnsSection(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context, LayoutState state) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppTextStyleNotifier.instance,
        AppFontSizeNotifier.instance,
      ]),
      builder: (context, _) {
        final textColor = AppTextStyleNotifier.instance.textColor;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                textColor.withValues(alpha: 0.15),
                textColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: textColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.eye_fill,
                    color: textColor.withValues(alpha: 0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Preview',
                    style: GoogleFonts.getFont(
                      AppTextStyleNotifier.instance.fontFamily,
                      textStyle: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                state.layoutType == AppLayoutType.list
                    ? 'List View'
                    : 'Grid View (${state.gridColumnCount} columns)',
                style: GoogleFonts.getFont(
                  AppTextStyleNotifier.instance.fontFamily,
                  textStyle: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                state.layoutType == AppLayoutType.list
                    ? 'Apps will be displayed in a vertical list with alphabet indexing'
                    : 'Apps will be arranged in a ${state.gridColumnCount}-column grid',
                style: GoogleFonts.getFont(
                  AppTextStyleNotifier.instance.fontFamily,
                  textStyle: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLayoutTypeSection(BuildContext context, LayoutState state) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppTextStyleNotifier.instance,
        AppFontSizeNotifier.instance,
      ]),
      builder: (context, _) {
        final textColor = AppTextStyleNotifier.instance.textColor;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFamily: AppTextStyleNotifier.instance.fontFamily,
              context: context,
              icon: CupertinoIcons.square_grid_2x2,
              title: 'Layout Type',
              child:_buildLayoutOption(
              context,
              layoutType: AppLayoutType.list,
              icon: CupertinoIcons.list_bullet,
              title: 'List View',
              description: 'Classic vertical list with alphabet navigation',
              isSelected: state.layoutType == AppLayoutType.list,
              onTap: () {
                context.read<LayoutCubit>().setLayoutType(AppLayoutType.list);
              },
            ),
            ),
            Padding(
             padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _buildLayoutOption(
                context,
                layoutType: AppLayoutType.grid,
                icon: CupertinoIcons.grid,
                title: 'Grid View',
                description: 'Compact grid layout with customizable columns',
                isSelected: state.layoutType == AppLayoutType.grid,
                onTap: () {
                  context.read<LayoutCubit>().setLayoutType(AppLayoutType.grid);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLayoutOption(
    BuildContext context, {
    required AppLayoutType layoutType,
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
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
              color: isSelected
                  ? textColor.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? textColor.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? textColor : textColor.withValues(alpha: 0.6),
                  size: 20,
                ),
                ConstantWidgets.width20(context),
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
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        description,
                        style: GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          textStyle: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: textColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridColumnsSection(BuildContext context, LayoutState state) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        AppTextStyleNotifier.instance,
        AppFontSizeNotifier.instance,
      ]),
      builder: (context, _) {
        final textColor = AppTextStyleNotifier.instance.textColor;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection(
              context: context,
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFamily: AppTextStyleNotifier.instance.fontFamily,
              icon: CupertinoIcons.slider_horizontal_3,
              title: 'Grid Columns',
              child: 
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [3, 4, 5, 6].map((columnCount) {
                final isSelected = state.gridColumnCount == columnCount;
                return GestureDetector(
                  onTap: () {
                    context.read<LayoutCubit>().setGridColumnCount(columnCount);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? textColor.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? textColor.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.15),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$columnCount',
                          style: GoogleFonts.getFont(
                            AppTextStyleNotifier.instance.fontFamily,
                            textStyle: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        Text(
                          'cols',
                          style: GoogleFonts.getFont(
                            AppTextStyleNotifier.instance.fontFamily,
                            textStyle: TextStyle(
                              color: textColor.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            ),
          ],
        );
      },
    );
  }
}