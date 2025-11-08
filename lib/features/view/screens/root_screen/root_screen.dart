import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:minilauncher/core/common/custom_snackbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view/screens/apps_screen/show_prioritized_apps.dart';
import 'package:minilauncher/features/view/widget/wallpaper_background.dart';
import 'package:minilauncher/features/view/widget/app_icon_widget.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_font_size_notifier.dart';
import 'package:minilauncher/core/service/screen_control_service.dart';
import 'package:minilauncher/features/view_model/bloc/root_bloc/root_bloc_dart_bloc.dart';
import 'package:minilauncher/features/view_model/cubit/prioritized_scroll_cubit.dart';
import 'package:minilauncher/features/view_model/cubit/double_tap_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  DateTime? _lastDoubleTapTime;
  bool _isProcessing = false;
  static const Duration _debounceDelay = Duration(milliseconds: 1000);

  Future<void> _handleDoubleTap() async {
    // Debounce to prevent multiple rapid calls
    final now = DateTime.now();

    // Check if already processing
    if (_isProcessing) {
      return; // Already processing, ignore
    }

    // Check if too soon after last double-tap
    if (_lastDoubleTapTime != null &&
        now.difference(_lastDoubleTapTime!) < _debounceDelay) {
      return; // Too soon after last double-tap, ignore
    }

    // Set flags immediately to prevent multiple calls
    _lastDoubleTapTime = now;
    _isProcessing = true;

    try {
      // Prefer device admin if available; otherwise suggest accessibility fallback
      final isAdmin = await ScreenControlService.isDeviceAdminEnabled();
      if (!isAdmin) {
        await ScreenControlService.requestDeviceAdmin();
        await ScreenControlService.openAccessibilitySettings();
        return;
      }
      final ok = await ScreenControlService.turnOffScreen();
      if (!ok) {
        // Prompt user to enable the Accessibility Service fallback
        await ScreenControlService.openAccessibilitySettings();
      }
    } catch (e) {
      // Silently handle errors - screen control may not be available on all devices
      debugPrint('Screen control error: $e');
    } finally {
      // Reset processing flag after a longer delay to ensure screen stays off
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoubleTapCubit, bool>(
      builder: (context, isDoubleTapEnabled) {
        return PopScope(
          canPop: false,
          child: SafeArea(
            child: GestureDetector(
              onDoubleTap: isDoubleTapEnabled ? _handleDoubleTap : null,
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: WallpaperBackground(child: bodyPartOfRootScreen(context)),
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget bodyPartOfRootScreen(BuildContext context) {
  return BlocBuilder<RootBloc, RootState>(
    buildWhen: (previous, current) => current is RootScreeBuildState,
    builder: (context, state) {
      if (state is SelectPriorityAppState) {
        return appsToSelectPriorityView(state, context);
      } else if (state is LoadPrioritizedAppsState) {
        return BlocProvider(
          create: (_) => PrioritizedScrollCubit(),
          child: ShowPrioritizedMainApps(state: state),
        );
      }
      return Center(
        child: Lottie.asset(
          'assets/energy_rocket.json',
          width: 150,
          height: 150,
        ),
      );
    },
  );
}

Widget appsToSelectPriorityView(
  SelectPriorityAppState state,
  BuildContext context,
) {
  const int maxSelectable = 13;

  return Scaffold(
    backgroundColor: Colors.transparent,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 15),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'Select Priority Apps (${state.selectedPackages.length})',
              style: GoogleFonts.getFont(
                AppTextStyleNotifier.instance.fontFamily,
                textStyle: TextStyle(
                  color: AppTextStyleNotifier.instance.textColor,
                  fontWeight: AppTextStyleNotifier.instance.fontWeight,
                  fontSize: AppFontSizeNotifier.instance.value,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: state.allApps.length,
            itemBuilder: (context, index) {
              final app = state.allApps[index].app;
              final packageName = app.packageName;

              return BlocSelector<RootBloc, RootState, bool>(
                selector: (state) {
                  if (state is SelectPriorityAppState) {
                    return state.selectedPackages.contains(packageName);
                  }
                  return false;
                },
                builder: (context, isSelected) {
                  return ValueListenableBuilder(
                    valueListenable: AppTextStyleNotifier.instance,
                    builder: (context, _, __) {
                      return ValueListenableBuilder(
                        valueListenable: AppFontSizeNotifier.instance,
                        builder: (context, ___, ____) {
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (_) {
                              if (!isSelected &&
                                  state.selectedPackages.length >=
                                      maxSelectable) {
                                CustomSnackBar.show(
                                  context,
                                  message: 'You can only select up to 13 apps',
                                  textAlign: TextAlign.center,
                                );
                                return;
                              }
                              context.read<RootBloc>().add(
                                TogglePriorityAppEvent(packageName),
                              );
                            },
                            title: Row(
                              children: [
                                AppIconWidget(
                                  iconData: app.icon,
                                  size: 40,
                                  appName: app.name,
                                ),
                                ConstantWidgets.width20(context),
                                Flexible(
                                  child: Text(
                                    app.name,
                                    style: GoogleFonts.getFont(
                                      AppTextStyleNotifier.instance.fontFamily,
                                      textStyle: TextStyle(
                                        color:
                                            AppTextStyleNotifier
                                                .instance
                                                .textColor,
                                        fontWeight:
                                            AppTextStyleNotifier
                                                .instance
                                                .fontWeight,
                                        fontSize:
                                            AppFontSizeNotifier.instance.value,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppPalette.orengeColor,
                            checkColor: AppPalette.whiteColor,
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    ),

    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: BlocBuilder<RootBloc, RootState>(
      buildWhen: (previous, current) => current is SelectPriorityAppState,
      builder: (context, state) {
        if (state is! SelectPriorityAppState) return const SizedBox();

        final bool canSave =
            state.selectedPackages.isNotEmpty &&
            state.selectedPackages.length <= maxSelectable;

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 55,
          child: FloatingActionButton.extended(
            backgroundColor:
                canSave
                    ? AppPalette.orengeColor
                    : AppPalette.blackColor.withValues(alpha: 0.5),
            label: Text(
              canSave
                  ? 'Save'
                  : state.selectedPackages.isEmpty
                  ? 'Select at least one'
                  : 'Max 13 apps allowed',
              style: GoogleFonts.getFont(
                AppTextStyleNotifier.instance.fontFamily,
                textStyle: TextStyle(
                  color: AppTextStyleNotifier.instance.textColor,
                  fontWeight: AppTextStyleNotifier.instance.fontWeight,
                  fontSize: AppFontSizeNotifier.instance.value,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            onPressed:
                canSave
                    ? () {
                      context.read<RootBloc>().add(
                        SavePriorityAppsEvent(
                          packageNames: state.selectedPackages.toList(),
                        ),
                      );
                    }
                    : null,
          ),
        );
      },
    ),
  );
}
