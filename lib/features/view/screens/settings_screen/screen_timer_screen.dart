import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/view_model/cubit/screen_timer_cubit.dart';
import 'package:minilauncher/features/view/widget/timer_picker_widget.dart';

import '../../../../core/common/custom_snackbar.dart';
import '../../../../core/service/app_usage_service.dart';
import '../../../model/data/app_usage_prefs.dart';

class ScreenTimerScreen extends StatelessWidget {
  const ScreenTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScreenTimerCubit(),
      child: Scaffold(
 
        appBar: CustomAppBar(
          title: 'Set Timer',
          backgroundColor: AppPalette.blackColor,
          isTitle: true,
        ),
        body: Column(
          children: [
            ConstantWidgets.hight20(context),
              
            // Instructions
            _buildInstructionSection(),
            
            ConstantWidgets.hight30(context),
            
            // Time Picker
            const Expanded(
              child: TimerPickerWidget(),
            ),
            
            ConstantWidgets.hight20(context),
            
            // Selected Time Display
            _buildSelectedTimeDisplay(),
            
            ConstantWidgets.hight30(context),
            
            // Set Button
            _buildSetButton(context),
            
            ConstantWidgets.hight30(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionSection() {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Set Reminder for screen time",
              style: GoogleFonts.getFont(
                AppTextStyleNotifier.instance.fontFamily,
                textStyle: TextStyle(
                  color: AppTextStyleNotifier.instance.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedTimeDisplay() {
    return BlocBuilder<ScreenTimerCubit, ScreenTimerState>(
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: AppTextStyleNotifier.instance,
          builder: (context, _, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: AppPalette.greyColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppPalette.greyColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.clock,
                    color: AppPalette.whiteColor,
                    size: 24,
                  ),
                  ConstantWidgets.width10(context),
                  Text(
                    'Selected: ',
                    style: GoogleFonts.getFont(
                      AppTextStyleNotifier.instance.fontFamily,
                      textStyle: TextStyle(
                        color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    '${state.hours}h ${state.minutes}m',
                    style: GoogleFonts.getFont(
                      AppTextStyleNotifier.instance.fontFamily,
                      textStyle: const TextStyle(
                        color: AppPalette.whiteColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSetButton(BuildContext context) {
    return BlocBuilder<ScreenTimerCubit, ScreenTimerState>(
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: AppTextStyleNotifier.instance,
          builder: (context, _, __) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    await _handleSetTimer(context, state);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.whiteColor,
                    foregroundColor: AppPalette.blackColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Set Timer',
                    style: GoogleFonts.getFont(
                      AppTextStyleNotifier.instance.fontFamily,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleSetTimer(
    BuildContext context,
    ScreenTimerState state,
  ) async {
    try {
      // Calculate total minutes
      final totalMinutes = state.hours * 60 + state.minutes;

      // Validate
      if (totalMinutes == 0) {
        CustomSnackBar.show(
          context,
          message: 'Please select at least 1 minute',
          backgroundColor: Colors.red,
          textAlign: TextAlign.center,
        );
        return;
      }

      // Check usage stats permission
      final hasUsagePermission = await AppUsageService.hasUsagePermission();

      if (!hasUsagePermission) {
        // Show usage permission explanation dialog
        if (context.mounted) {
          await _showPermissionDialog(context, isUsagePermission: true);
        }
        return;
      }

      // Check notification permission (Android 13+)
      final hasNotificationPermission = await AppUsageService.hasNotificationPermission();

      if (!hasNotificationPermission) {
        // Show notification permission explanation dialog
        if (context.mounted) {
          await _showPermissionDialog(context, isUsagePermission: false);
        }
        return;
      }

      // Save time limit
      await AppUsagePrefs().setTimeLimit(totalMinutes);

      // 🔄 SMART RESET: Clear all notification tracking for fresh start
      // This allows users to get new notifications based on the NEW limit
      await AppUsagePrefs().clearNotifiedApps();
      await AppUsageService.resetNotifications();

      // Start monitoring service
      await AppUsageService.startMonitoring(totalMinutes);

      // Save monitoring status
      await AppUsagePrefs().setMonitoringEnabled(true);

      // Show success message
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message:
              'Timer set for ${state.hours}h ${state.minutes}m. Monitoring started!',
          backgroundColor: AppPalette.greenColor,
          textAlign: TextAlign.center,
        );

        // Close screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'Error: ${e.toString()}',
          backgroundColor: Colors.red,
          textAlign: TextAlign.center,
        );
      }
    }
  }

  Future<void> _showPermissionDialog(
    BuildContext context, {
    required bool isUsagePermission,
  }) async {
    final title = isUsagePermission ? 'Usage Stats Permission' : 'Notification Permission';
    final icon = isUsagePermission ? CupertinoIcons.chart_bar_fill : CupertinoIcons.bell_fill;
    final message = isUsagePermission
        ? 'To track app usage, we need permission to access usage statistics. This helps monitor how much time you spend on each app.'
        : 'To send you screen time alerts, we need permission to show notifications. You\'ll be notified when you exceed your time limit.';
    
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.blackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPalette.orengeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppPalette.orengeColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.getFont(
                  AppTextStyleNotifier.instance.fontFamily,
                  textStyle: TextStyle(
                    color: AppTextStyleNotifier.instance.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.getFont(
            AppTextStyleNotifier.instance.fontFamily,
            textStyle: TextStyle(
              color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.getFont(
                AppTextStyleNotifier.instance.fontFamily,
                textStyle: TextStyle(
                  color: AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              if (isUsagePermission) {
                await AppUsageService.requestUsagePermission();
                
                // Wait a bit for user to grant permission
                await Future.delayed(const Duration(seconds: 2));
                
                // Check if permission was granted
                if (context.mounted) {
                  final hasPermission = await AppUsageService.hasUsagePermission();
                  if (hasPermission) {
                    CustomSnackBar.show(
                      context,
                      message: 'Permission granted! Now set your timer.',
                      backgroundColor: AppPalette.greenColor,
                      textAlign: TextAlign.center,
                    );
                  }
                }
              } else {
                // Request notification permission
                await AppUsageService.requestNotificationPermission();
                
                // Wait a bit for user to grant permission
                await Future.delayed(const Duration(seconds: 1));
                
                // Check if permission was granted
                if (context.mounted) {
                  final hasPermission = await AppUsageService.hasNotificationPermission();
                  if (hasPermission) {
                    CustomSnackBar.show(
                      context,
                      message: 'Notification permission granted! Now set your timer.',
                      backgroundColor: AppPalette.greenColor,
                      textAlign: TextAlign.center,
                    );
                  } else {
                    CustomSnackBar.show(
                      context,
                      message: 'Notification permission denied. You won\'t receive alerts.',
                      backgroundColor: Colors.orange,
                      textAlign: TextAlign.center,
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orengeColor,
              foregroundColor: AppPalette.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Grant Permission',
              style: GoogleFonts.getFont(
                AppTextStyleNotifier.instance.fontFamily,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
        );
  }
}

