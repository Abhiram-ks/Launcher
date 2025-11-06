import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minilauncher/core/constant/app_icon_shape.dart';
import 'package:minilauncher/core/service/app_icon_shape_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/model/data/app_icon_shape_prefs.dart';

import '../../../../core/common/custom_appbar.dart';
import '../../../../core/common/custom_snackbar.dart';

class SelectShapeScreen extends StatefulWidget {
  const SelectShapeScreen({super.key});

  @override
  State<SelectShapeScreen> createState() => _SelectShapeScreenState();
}

class _SelectShapeScreenState extends State<SelectShapeScreen> {
  AppIconShape? _selectedShape;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentShape();
    // Listen to shape changes
    AppIconShapeNotifier.instance.addListener(_onShapeChanged);
  }

  @override
  void dispose() {
    AppIconShapeNotifier.instance.removeListener(_onShapeChanged);
    super.dispose();
  }

  void _onShapeChanged() {
    setState(() {
      _selectedShape = AppIconShapeNotifier.instance.value;
    });
  }

  Future<void> _loadCurrentShape() async {
    final shape = await AppIconShapePrefs().getShape();
    setState(() {
      _selectedShape = shape;
      _isLoading = false;
    });
  }

  Future<void> _saveShape(AppIconShape shape) async {
    await AppIconShapePrefs().setShape(shape);
    setState(() {
      _selectedShape = shape;
    });
    // Show confirmation
    if (mounted) {
      CustomSnackBar.show(context, message: 'Shape changed to ${shape.displayName}', backgroundColor: AppPalette.greenColor, textColor: AppPalette.whiteColor,durationSeconds: 1, textAlign: TextAlign.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(title: 'Change Icon Shape', backgroundColor: AppPalette.blackColor, titleColor: AppPalette.whiteColor, iconColor: AppPalette.whiteColor,isTitle: true,),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppPalette.orengeColor,
              ),
            )
          : ListView(
              children: AppIconShape.values.map((shape) {
                final isSelected = _selectedShape == shape;
                return ListTile(
                  leading: _buildShapePreview(shape, isSelected),
                  title: Text(
                    shape.displayName,
                    style: TextStyle(
                      color: isSelected ? AppPalette.whiteColor : AppPalette.hintColor,
                      fontSize: isSelected ? 15 : 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark_alt,
                          color: AppPalette.orengeColor,
                        )
                      : null,
                  onTap: () => _saveShape(shape),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildShapePreview(AppIconShape shape, bool isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppPalette.orengeColor : Colors.white30,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: _getBorderRadius(shape),
        color: Colors.white10,
      ),
      child: ClipRRect(
        borderRadius: _getBorderRadius(shape),
        child: Container(
          color: AppPalette.orengeColor.withValues(alpha: 0.3),
          child: Icon(
            Icons.apps,
            color: AppPalette.whiteColor,
            size: 30,
          ),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(AppIconShape shape) {
    switch (shape) {
      case AppIconShape.rectangle:
        return BorderRadius.circular(8);
      case AppIconShape.circle:
        return BorderRadius.circular(25);
      case AppIconShape.square:
        return BorderRadius.zero;
      case AppIconShape.clipped:
        return const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        );
    }
  }
}

