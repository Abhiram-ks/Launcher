import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/constant/app_font_weights.dart';
import 'package:minilauncher/core/constant/app_font_sizes.dart';
import 'package:minilauncher/core/constant/app_text_colors.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view_model/cubit/text_style_cubit.dart';

import '../../../../core/common/custom_appbar.dart';

class SelectTextStyleScreen extends StatelessWidget {
  const SelectTextStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TextStyleCubit()..load(),
      child: const _SelectTextStyleScreenBody(),
    );
  }
}

class _SelectTextStyleScreenBody extends StatelessWidget {
  const _SelectTextStyleScreenBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TextStyleCubit, TextStyleState>(
      builder: (context, ts) {
        if (ts.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: CircularProgressIndicator(color: AppPalette.orengeColor),
            ),
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Style Settings',
            isTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewSection(context, ts),
                ConstantWidgets.hight10(context),
                // Text Color Section
                buildSection(
                  context: context,
                  color: ts.color,
                  fontWeight: ts.fontWeight,
                  fontFamily: ts.fontFamily,
                  icon: CupertinoIcons.paintbrush_fill,
                  title: 'Color Palette',
                  child: _buildColorPicker(context, ts),
                ),
                
                // Font Family Section
                buildSection(
                  context: context,
                  color: ts.color,
                  fontWeight: ts.fontWeight,
                  fontFamily: ts.fontFamily,
                  icon: CupertinoIcons.textformat,
                  title: 'Font Family',
                  child: _buildFontFamilySelector(context, ts),
                ),
                
                // Font Weight Section
                buildSection(
                  context: context,
                  color: ts.color,
                  fontWeight: ts.fontWeight,
                  fontFamily: ts.fontFamily,
                  icon: CupertinoIcons.bold,
                  title: 'Font Weight',
                  child: _buildFontWeightSelector(context, ts),
                ),
                
                // Font Size Section
                buildSection(
                  context: context,
                  color: ts.color,
                  fontWeight: ts.fontWeight,
                  fontFamily: ts.fontFamily,
                  icon: CupertinoIcons.textformat_size,
                  title: 'Font Size',
                  child: _buildFontSizeSelector(context, ts),
                ),
                ConstantWidgets.hight20(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // Section Builder

  // Preview Section
  static Widget _buildPreviewSection(BuildContext context, TextStyleState ts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ts.color.withValues(alpha: 0.15),
            ts.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ts.color.withValues(alpha: 0.3),
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
                color: ts.color.withValues(alpha: 0.7),
                size: 16,
              ),
              ConstantWidgets.width10(context),
              Text(
                'Preview',
                style: GoogleFonts.getFont(
                  ts.fontFamily,
                  textStyle: TextStyle(
                    color: ts.color.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Sample App Name',
            style: GoogleFonts.getFont(
              ts.fontFamily,
              textStyle: TextStyle(
                color: ts.color,
                fontWeight: ts.fontWeight,
                fontSize: ts.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Color Picker
  static Widget _buildColorPicker(BuildContext context, TextStyleState ts) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: AppTextColors.availableColors.map((color) {
        final isSelected = ts.color == color;
        return GestureDetector(
          onTap: () => context.read<TextStyleCubit>().setColor(color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 30 : 26,
            height: isSelected ? 30 : 26,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppPalette.orengeColor : Colors.white24,
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(
                    CupertinoIcons.checkmark_alt,
                    color: Colors.black87,
                    size: 22,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  // Font Family Selector
  static Widget _buildFontFamilySelector(BuildContext context, TextStyleState ts) {
    const fontFamilies = [
      'Roboto',
      'Poppins',
      'Lato',
      'Open Sans',
      'Montserrat',
      'Inter',
      'Nunito',
      'Nunito Sans',
      'Source Sans 3',
      'Work Sans',
      'Rubik',
      'Raleway',
      'Oswald',
      'Playfair Display',
      'Merriweather',
      'Manrope',
      'DM Sans',
      'Quicksand',
      'Ubuntu',
      'Noto Sans',
      'Noto Serif',
      'PT Sans',
      'PT Serif',
      'Heebo',
      'Mulish',
      'Barlow',
      'Space Grotesk',
      'Titillium Web',
      'Cabin',
      'Josefin Sans',
    ];

    return Wrap(
      spacing: 4,
      runSpacing: 1,
      children: fontFamilies.map((family) {
        final isSelected = ts.fontFamily == family;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ChoiceChip(
            selected: isSelected,
            label: Text(
              family,
              style: GoogleFonts.getFont(
                family,
                textStyle: TextStyle(
                  color:  ts.color ,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            selectedColor: ts.color.withValues(alpha: 0.25),
            backgroundColor: ts.color.withValues(alpha: 0.05),
            side: BorderSide(
              color: isSelected
                  ? ts.color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 1.5 : 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            onSelected: (_) => context.read<TextStyleCubit>().setFontFamily(family),
            iconTheme: IconThemeData(color: ts.color),
          ),
        );
      }).toList(),
    );
  }

  // Font Weight Selector
  static Widget _buildFontWeightSelector(BuildContext context, TextStyleState ts) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ts.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<FontWeight>(
          value: ts.fontWeight,
          isExpanded: true,
          style: TextStyle(color: ts.color, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          icon: Icon(CupertinoIcons.chevron_down, color: ts.color, size: 20),
          items: AppFontWeights.availableWeights.map((weight) {
            final normalizedSelected = AppFontWeights.normalizeWeight(ts.fontWeight);
            final normalizedWeight = AppFontWeights.normalizeWeight(weight);
            final isSelected = normalizedSelected == normalizedWeight;
            
            return DropdownMenuItem<FontWeight>(
              value: weight,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppFontWeights.getWeightName(weight),
                      style: TextStyle(
                        fontWeight: weight,
                        color: ts.color,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      CupertinoIcons.checkmark_alt,
                      color: ts.color,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newWeight) {
            if (newWeight != null) {
              context.read<TextStyleCubit>().setFontWeight(newWeight);
            }
          },
        ),
      ),
    );
  }

  // Font Size Selector
  static Widget _buildFontSizeSelector(BuildContext context, TextStyleState ts) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ts.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: ts.fontSize,
          isExpanded: true,
          style: TextStyle(color: ts.color, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          icon: Icon(CupertinoIcons.chevron_down, color: ts.color, size: 20),
          items: AppFontSizes.availableSizes.map((size) {
            final isSelected = ts.fontSize == size;
            
            return DropdownMenuItem<double>(
              value: size,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppFontSizes.getSizeName(size),
                      style: TextStyle(
                        fontSize: size,
                        color: ts.color,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      CupertinoIcons.checkmark_alt,
                      color: ts.color,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (newSize) {
            if (newSize != null) {
              context.read<TextStyleCubit>().setFontSize(newSize);
            }
          },
        ),
      ),
    );
  }
}


   Widget buildSection({
    required BuildContext context,
    required Color color,
    required FontWeight fontWeight,
    required String fontFamily,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              ConstantWidgets.width10(context),
              Text(
                title,
                style: GoogleFonts.getFont(
                  fontFamily,
                  textStyle: TextStyle(
                    color: color,
                    fontWeight: fontWeight,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          ConstantWidgets.hight10(context),
          child,
        ],
      ),
    );
  }
