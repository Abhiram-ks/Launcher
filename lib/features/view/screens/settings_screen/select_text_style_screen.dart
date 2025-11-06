import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/constant/app_font_weights.dart';
import 'package:minilauncher/core/constant/app_font_sizes.dart';
import 'package:minilauncher/core/constant/app_text_colors.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/model/data/app_text_style_prefs.dart';
import 'package:minilauncher/features/model/data/app_font_size_prefs.dart';
import '../../../../core/common/custom_appbar.dart';
import '../../../../core/common/custom_snackbar.dart';

class SelectTextStyleScreen extends StatefulWidget {
  const SelectTextStyleScreen({super.key});

  @override
  State<SelectTextStyleScreen> createState() => _SelectTextStyleScreenState();
}

class _SelectTextStyleScreenState extends State<SelectTextStyleScreen> {
  Color? _selectedColor;
  FontWeight? _selectedFontWeight;
  double? _selectedFontSize;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStyle();
    AppTextStyleNotifier.instance.addListener(_onStyleChanged);
    AppFontSizeNotifier.instance.addListener(_onStyleChanged);
  }

  @override
  void dispose() {
    AppTextStyleNotifier.instance.removeListener(_onStyleChanged);
    AppFontSizeNotifier.instance.removeListener(_onStyleChanged);
    super.dispose();
  }

  void _onStyleChanged() {
    setState(() {
      _selectedColor = AppTextStyleNotifier.instance.textColor;
      _selectedFontWeight = AppTextStyleNotifier.instance.fontWeight;
      _selectedFontSize = AppFontSizeNotifier.instance.value;
    });
  }

  Future<void> _loadCurrentStyle() async {
    final color = await AppTextStylePrefs().getTextColor();
    final fontWeight = await AppTextStylePrefs().getFontWeight();
    final fontSize = await AppFontSizePrefs().getSize();
    // Normalize the font weight to ensure it matches one in the dropdown
    final normalizedWeight = AppFontWeights.normalizeWeight(fontWeight);
    setState(() {
      _selectedColor = color;
      _selectedFontWeight = normalizedWeight;
      _selectedFontSize = fontSize;
      _isLoading = false;
    });
    AppTextStyleNotifier.instance.updateTextStyle(color, normalizedWeight);
  }

  Future<void> _saveColor(Color color) async {
    await AppTextStylePrefs().setTextColor(color);
    AppTextStyleNotifier.instance.updateTextColor(color);
    if (mounted) {
      CustomSnackBar.show(
        context,
        message: 'Text color changed',
        backgroundColor: AppPalette.greenColor,
        textColor: AppPalette.whiteColor,
        durationSeconds: 1,
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> _saveFontWeight(FontWeight fontWeight) async {
    await AppTextStylePrefs().setFontWeight(fontWeight);
    AppTextStyleNotifier.instance.updateFontWeight(fontWeight);
    if (mounted) {
      CustomSnackBar.show(
        context,
        message: 'Font weight changed to ${AppFontWeights.getWeightName(fontWeight)}',
        backgroundColor: AppPalette.greenColor,
        textColor: AppPalette.whiteColor,
        durationSeconds: 1,
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> _saveFontSize(double fontSize) async {
    await AppFontSizePrefs().setSize(fontSize);
    AppFontSizeNotifier.instance.updateSize(fontSize);
    if (mounted) {
      CustomSnackBar.show(
        context,
        message: 'Font size changed to ${AppFontSizes.getSizeName(fontSize)}',
        backgroundColor: AppPalette.greenColor,
        textColor: AppPalette.whiteColor,
        durationSeconds: 1,
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        title: 'Text Style Settings',
        backgroundColor: AppPalette.blackColor,
        titleColor: AppPalette.whiteColor,
        iconColor: AppPalette.whiteColor,
        isTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppPalette.orengeColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Text Color',
                      style: TextStyle(
                        color: AppPalette.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: AppTextColors.availableColors.map((color) {
                        final isSelected = _selectedColor != null && 
                            _selectedColor == color;
                        return GestureDetector(
                          onTap: () => _saveColor(color),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppPalette.orengeColor 
                                    : Colors.white30,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Colors.black,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  ConstantWidgets.hight10(context),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Font Weight',
                      style: TextStyle(
                        color: AppPalette.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white30,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<FontWeight>(
                          value: _selectedFontWeight != null 
                              ? AppFontWeights.normalizeWeight(_selectedFontWeight!)
                              : null,
                          isExpanded: true,
                          dropdownColor: Colors.grey.shade900,
                          style: TextStyle(
                            color: AppPalette.whiteColor,
                            fontSize: 15,
                          ),
                          icon: Icon(
                            CupertinoIcons.chevron_down,
                            color: AppPalette.whiteColor,
                          ),
                          items: AppFontWeights.availableWeights.map((weight) {
                            final normalizedSelected = AppFontWeights.normalizeWeight(_selectedFontWeight ?? FontWeight.normal);
                            final normalizedWeight = AppFontWeights.normalizeWeight(weight);
                            final isSelected = normalizedSelected == normalizedWeight;
                            return DropdownMenuItem<FontWeight>(
                              value: weight,
                              child: Row(
                                children: [
                                  ConstantWidgets.width20(context),
                              
                                  Expanded(
                                    child: Text(
                                      AppFontWeights.getWeightName(weight),
                                      style: TextStyle(
                                        fontWeight: weight,
                                        color: AppPalette.whiteColor,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      CupertinoIcons.checkmark_alt,
                                      color: AppPalette.orengeColor,
                                      size: 18,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (FontWeight? newWeight) {
                            if (newWeight != null) {
                              _saveFontWeight(newWeight);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  ConstantWidgets.hight10(context),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Font Size',
                      style: TextStyle(
                        color: AppPalette.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white30,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<double>(
                          value: _selectedFontSize,
                          isExpanded: true,
                          dropdownColor: Colors.grey.shade900,
                          style: TextStyle(
                            color: AppPalette.whiteColor,
                            fontSize: 15,
                          ),
                          icon: Icon(
                            CupertinoIcons.chevron_down,
                            color: AppPalette.whiteColor,
                          ),
                          items: AppFontSizes.availableSizes.map((size) {
                            final isSelected = _selectedFontSize == size;
                            return DropdownMenuItem<double>(
                              value: size,
                              child: Row(
                                children: [
                                  ConstantWidgets.width20(context),
                                  Expanded(
                                    
                                    child: Text(
                                      AppFontSizes.getSizeName(size),
                                      style: TextStyle(
                                        fontSize: size,
                                        color:  AppPalette.whiteColor,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      CupertinoIcons.checkmark_alt,
                                      color: AppPalette.orengeColor,
                                      size: 18,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (double? newSize) {
                            if (newSize != null) {
                              _saveFontSize(newSize);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  ConstantWidgets.hight10(context),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: TextStyle(
                            color: AppPalette.whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Sample App Name',
                            style: TextStyle(
                              color: _selectedColor ?? AppPalette.whiteColor,
                              fontWeight: _selectedFontWeight ?? FontWeight.normal,
                              fontSize: _selectedFontSize ?? AppFontSizes.defaultSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

