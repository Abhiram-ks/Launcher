import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minilauncher/core/common/custom_snackbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import '../../../../core/common/custom_appbar.dart';
import '../../../../core/common/custom_dialogbox.dart';
import '../../../../core/service/app_text_style_notifier.dart';
import '../../../../core/service/app_customization_helper.dart';
import '../../../model/data/pick_image.dart';
import '../../../model/data/app_customization_prefs.dart';
import '../../../presentation/bloc/Image_picker_bloc/image_picker_bloc.dart';
import '../../../presentation/bloc/change_icon_name_bloc/change_icon_name_bloc.dart';
import '../../../view_model/cubit/edit_app_name_cubit.dart';
import '../../../view_model/cubit/app_icon_cubit.dart';
import '../../widget/app_icon_widget.dart';

class IntivitualAppHandleScreen extends StatefulWidget {
  final String packageName;
  final String appName;
  const IntivitualAppHandleScreen({
    super.key,
    required this.packageName,
    required this.appName,
  });

  @override
  State<IntivitualAppHandleScreen> createState() =>
      _IntivitualAppHandleScreenState();
}

class _IntivitualAppHandleScreenState extends State<IntivitualAppHandleScreen>
    with AutomaticKeepAliveClientMixin<IntivitualAppHandleScreen> {
  @override
  bool get wantKeepAlive => true;

  late final TextEditingController _appNameController;
  String? _pickedImagePath;
  String? _customIconPath;
  String _displayName = '';

  @override
  void initState() {
    super.initState();
    _loadExistingCustomizations();
  }

  void _loadExistingCustomizations() {
    // Load custom name if exists
    final customName = AppCustomizationPrefs.instance.getNewAppName(widget.packageName);
    _displayName = customName ?? widget.appName;
    _appNameController = TextEditingController(text: _displayName);

    // Load custom icon path if exists
    _customIconPath = AppCustomizationPrefs.instance.getNewAppIcon(widget.packageName);
    if (_customIconPath != null) {
      _pickedImagePath = _customIconPath;
    }
  }

  @override
  void dispose() {
    _appNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.packageName.isEmpty || widget.appName.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ImagePickerBloc(
                imagePicker: PickImageClass(imagePicker: ImagePicker()),
              ),
        ),
        BlocProvider(create: (context) => EditAppNameCubit()),
        BlocProvider(
          create: (context) => AppIconCubit(packageName: widget.packageName),
        ),
        BlocProvider(create: (context) => ChangeIconNameBloc()),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<ImagePickerBloc, ImagePickerState>(
            listener: (context, state) {
              if (state is ImagePickerLoaded) {
                _pickedImagePath = state.imagePath;
              }
            },
            child: StreamBuilder<Map<String, dynamic>?>(
              stream: AppCustomizationPrefs.instance.watchCustomization(widget.packageName),
              builder: (context, snapshot) {
                final displayName = AppCustomizationHelper.getCustomizedAppName(
                  widget.packageName,
                  widget.appName,
                );
                
                // Update text controller if customization changed
                if (_appNameController.text != displayName) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _appNameController.text = displayName;
                    }
                  });
                }
                
                return Scaffold(
                  appBar: CustomAppBar(title: displayName, isTitle: true),
                  body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ConstantWidgets.hight20(context),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          BlocBuilder<AppIconCubit, AppIconState>(
                            builder: (context, iconState) {
                              // Show loading indicator while icon is being fetched
                              if (iconState.isLoading) {
                                return SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color:
                                          AppTextStyleNotifier
                                              .instance
                                              .textColor,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }

                              // Show error state if icon failed to load
                              if (iconState.error != null) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppPalette.redColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    iconState.error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppPalette.redColor,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }

                              // Show picked image or app icon
                              return StreamBuilder<Map<String, dynamic>?>(
                                stream: AppCustomizationPrefs.instance.watchCustomization(widget.packageName),
                                builder: (context, customizationSnapshot) {
                                  return BlocBuilder<
                                    ImagePickerBloc,
                                    ImagePickerState
                                  >(
                                    builder: (context, pickerState) {
                                      // Show picked image if user just picked one
                                      if (pickerState is ImagePickerLoaded) {
                                        return ClipOval(
                                          child: Image.file(
                                            File(pickerState.imagePath),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      // Show error state from image picker
                                      else if (pickerState is ImagePickerError) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppPalette.redColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            pickerState.error,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppPalette.redColor,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }
                                      // Show loading when picking image
                                      else if (pickerState is ImagePickerLoading) {
                                        return SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color:
                                                  AppTextStyleNotifier
                                                      .instance
                                                      .textColor,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      }
                                      
                                      // Show custom icon if exists, otherwise show original
                                      final customIconPath = AppCustomizationHelper.getCustomizedAppIconPath(
                                        widget.packageName,
                                      );
                                      
                                      return ClipOval(
                                        child: AppIconWidget(
                                          iconData: iconState.icon,
                                          iconPath: customIconPath,
                                          size: 100,
                                          appName: _displayName,
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),

                          Positioned(
                            top: 0,
                            left: 0,

                            child: InkWell(
                              onTap: () {
                                context.read<ImagePickerBloc>().add(
                                  PickImageAction(),
                                );
                              },
                              child: ClipOval(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  color: AppPalette.blueColor,
                                  child: Icon(
                                    Icons.image_search_sharp,
                                    color: AppPalette.whiteColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: StreamBuilder<Map<String, dynamic>?>(
                            stream: AppCustomizationPrefs.instance.watchCustomization(widget.packageName),
                            builder: (context, snapshot) {
                              final displayName = AppCustomizationHelper.getCustomizedAppName(
                                widget.packageName,
                                widget.appName,
                              );
                              
                              return Text(
                                displayName,
                                style: GoogleFonts.getFont(
                                  AppTextStyleNotifier.instance.fontFamily,
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    color: AppTextStyleNotifier.instance.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              );
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<EditAppNameCubit>().toggle();
                          },
                          icon: Icon(
                            CupertinoIcons.pencil,
                            color: AppTextStyleNotifier.instance.textColor,
                            size: 15,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    BlocBuilder<EditAppNameCubit, bool>(
                      builder: (context, isEditing) {
                        if (!isEditing) return const SizedBox.shrink();

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: TextFormField(
                            controller: _appNameController,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              AppTextStyleNotifier.instance.fontFamily,
                              textStyle: TextStyle(
                                fontSize: 14,
                                color: AppTextStyleNotifier.instance.textColor,
                              ),
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Enter app name',
                              hintStyle: GoogleFonts.getFont(
                                AppTextStyleNotifier.instance.fontFamily,
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color:
                                      AppTextStyleNotifier.instance.textColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      AppTextStyleNotifier.instance.textColor,
                                  width: 0.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color:
                                      AppTextStyleNotifier.instance.textColor,
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      widget.packageName,
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: AppTextStyleNotifier.instance.textColor,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    ConstantWidgets.hight20(context),
                    BlocListener<ChangeIconNameBloc, ChangeIconNameState>(
                      listener: (context, state) {
                        handleSaveChangesState(context, state);
                      },
                      child: BlocBuilder<
                        ChangeIconNameBloc,
                        ChangeIconNameState
                      >(
                        builder: (context, state) {
                          return TextButton(
                            onPressed:
                                state is SaveChangesLoadingState
                                    ? null
                                    : () {
                                      final newName =
                                          _appNameController.text.trim();
                                      // Compare with original app name, not custom name
                                      final originalName = AppCustomizationHelper.getCustomizedAppName(
                                        widget.packageName,
                                        widget.appName,
                                      );
                                      final hasNameChange =
                                          newName.isNotEmpty &&
                                          newName != originalName;
                                      final hasIconChange =
                                          _pickedImagePath != null &&
                                          _pickedImagePath != _customIconPath;

                                      if (!hasNameChange && !hasIconChange) {
                                        CustomSnackBar.show(
                                          context,
                                          message: 'No changes to save',
                                          backgroundColor: AppPalette.redColor,
                                          textAlign: TextAlign.center,
                                        );
                                        return;
                                      }

                                      CustomCupertinoDialog.show(
                                        context: context,
                                        title: 'Save Changes',
                                        message:
                                            hasNameChange && hasIconChange
                                                ? 'Save new app name and icon?'
                                                : hasNameChange
                                                ? 'Save new app name?'
                                                : 'Save new app icon?',
                                        firstButtonText: 'Save',
                                        secondButtonText: 'Cancel',
                                        firstButtonColor:
                                            AppTextStyleNotifier
                                                .instance
                                                .textColor,
                                        onTap: () {
                                          context
                                              .read<ChangeIconNameBloc>()
                                              .add(
                                                SaveChangesEvent(
                                                  appPackageName:
                                                      widget.packageName,
                                                  newappName:
                                                      hasNameChange
                                                          ? newName
                                                          : null,
                                                  newappIcon:
                                                      hasIconChange
                                                          ? _pickedImagePath
                                                          : null,
                                                ),
                                              );
                                        },
                                      );
                                    },
                            style: TextButton.styleFrom(
                              backgroundColor: AppPalette.blueColor,
                              foregroundColor: AppPalette.whiteColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                state is SaveChangesLoadingState
                                    ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppPalette.whiteColor,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      'Save Changes',
                                      style: GoogleFonts.getFont(
                                        AppTextStyleNotifier
                                            .instance
                                            .fontFamily,
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          color:
                                              AppTextStyleNotifier
                                                  .instance
                                                  .textColor,
                                        ),
                                      ),
                                    ),
                          );
                        },
                      ),
                    ),
                    ConstantWidgets.hight10(context),
                    Text(
                      'Reset to Default?',
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: AppTextStyleNotifier.instance.textColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
                  );
              },
            ),
          );
        },
      ),
    );
  }
}

void handleSaveChangesState(BuildContext ctx, ChangeIconNameState state) {
  if (state is SaveChangesSuccessState) {
    Navigator.pop(ctx);
  } else if (state is SaveChangesErrorState) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(state.error),
        backgroundColor: AppPalette.redColor,
      ),
    );
  } else if (state is SaveChangesErrorState) {
    CustomSnackBar.show(
      ctx,
      message: state.error,
      backgroundColor: AppPalette.redColor,
      textAlign: TextAlign.center,
    );
  }
}
