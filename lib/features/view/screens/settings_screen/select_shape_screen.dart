import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/constant/app_icon_shape.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view_model/cubit/shape_selection_cubit.dart';

import '../../../../core/common/custom_appbar.dart';
import '../../../../core/common/custom_snackbar.dart';
import '../../../../core/service/app_text_style_notifier.dart';

class SelectShapeScreen extends StatelessWidget {
  const SelectShapeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShapeSelectionCubit()..load(),
      child: const _SelectShapeScreenBody(),
    );
  }
}

class _SelectShapeScreenBody extends StatelessWidget {
  const _SelectShapeScreenBody();

  void _saveShape(BuildContext context, AppIconShape shape) async {
    await context.read<ShapeSelectionCubit>().setShape(shape);
    if (context.mounted) {
      CustomSnackBar.show(
        context,
        message: 'Shape changed to ${shape.displayName}',
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
      appBar: CustomAppBar(
        title: 'Change Icon Shape',
        isTitle: true,
      ),
      body: BlocBuilder<ShapeSelectionCubit, ShapeSelectionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppPalette.orengeColor),
            );
          }

          return ListView(
            children: AppIconShape.values.map((shape) {
              final isSelected = state.shape == shape;
              return ListTile(
                leading: _buildShapePreview(shape, isSelected),
                title: Text(
                  shape.displayName,
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    color: AppTextStyleNotifier.instance.textColor,
                    fontSize: isSelected ? 15 : 13,
                    fontWeight:
                        isSelected
                            ? FontWeight.bold
                            : AppTextStyleNotifier.instance.fontWeight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
                trailing:
                    isSelected
                        ? Icon(
                          CupertinoIcons.checkmark_alt,
                          color: AppTextStyleNotifier.instance.textColor,
                        )
                        : null,
                subtitle: Row(
                  children: [
                    if (shape.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppPalette.orengeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Popular',
                          style: GoogleFonts.getFont(
                            AppTextStyleNotifier.instance.fontFamily,
                            color: AppPalette.whiteColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ConstantWidgets.width10(context),
                    Expanded(
                      child: Text(
                        shape.description,
                        style: GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          color: AppTextStyleNotifier.instance.textColor,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                onTap: () => _saveShape(context, shape),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildShapePreview(AppIconShape shape, bool isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppTextStyleNotifier.instance.textColor : Colors.white30,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: _getBorderRadius(shape),
        color: Colors.white10,
      ),
      child: ClipRRect(
        borderRadius: _getBorderRadius(shape),
        child: Container(
          color:  AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.3),
          child: Icon(Icons.apps, color: AppPalette.whiteColor, size: 30),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(AppIconShape shape) {
    switch (shape) {
      case AppIconShape.squircle:
        return BorderRadius.circular(15); // iOS-style smooth rounded
      case AppIconShape.circle:
        return BorderRadius.circular(25);
      case AppIconShape.roundedSquare:
        return BorderRadius.circular(12);
      case AppIconShape.rectangle:
        return BorderRadius.circular(8);
      case AppIconShape.teardrop:
        return const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        );
      case AppIconShape.pebble:
        return BorderRadius.circular(18);
      case AppIconShape.clipped:
        return const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );
      case AppIconShape.hexagon:
        return BorderRadius.circular(6); // Slight rounding for hex effect
      case AppIconShape.octagon:
        return BorderRadius.circular(8); // Slight rounding for octagon effect
      case AppIconShape.leaf:
        return const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(5),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(20),
        );
      case AppIconShape.square:
        return BorderRadius.zero;
      case AppIconShape.stadium:
        return BorderRadius.circular(25); // Pill shape
    }
  }
}
