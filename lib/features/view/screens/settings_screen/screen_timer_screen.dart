import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/common/custom_snackbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_usage_service.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/model/data/app_usage_prefs.dart';
import 'package:minilauncher/features/model/data/priority_apps_localdb.dart';
import 'package:minilauncher/features/view/screens/screen_time_activity/screen_time_activity.dart';
import 'package:minilauncher/features/view/widget/timer_picker_widget.dart';
import 'package:minilauncher/features/view_model/cubit/screen_timer_cubit.dart';

class ScreenTimerScreen extends StatelessWidget {
  const ScreenTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScreenTimerCubit(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Screen Timer',
          backgroundColor: AppPalette.blackColor,
          isTitle: true,
        ),
        body: Column(
          children: [
            ConstantWidgets.hight20(context),

            // Header with Activity Link
            _buildHeaderSection(context),

            ConstantWidgets.hight30(context),

            // Info Card
        //    _buildInfoCard(context),

            ConstantWidgets.hight20(context),

            // Monitoring Toggle
            _buildMonitoringToggle(context),

            ConstantWidgets.hight30(context),

            // Time Picker
            const Expanded(child: TimerPickerWidget()),

            ConstantWidgets.hight20(context),

            // Selected Time Display
            _buildSelectedTimeDisplay(context),

            ConstantWidgets.hight30(context),

            // Set Button
            _buildSetButton(context),

            ConstantWidgets.hight30(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Time Limit',
                    style: GoogleFonts.getFont(
                      AppTextStyleNotifier.instance.fontFamily,
                      textStyle: TextStyle(
                        color: AppTextStyleNotifier.instance.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Control your screen time',
                    style: GoogleFonts.getFont(
                      AppTextStyleNotifier.instance.fontFamily,
                      textStyle: TextStyle(
                        color: AppTextStyleNotifier.instance.textColor
                            .withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreenTimeActivity(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.blueColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppPalette.blueColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        color: AppPalette.blueColor,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'View Stats',
                        style: GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          textStyle: const TextStyle(
                            color: AppPalette.blueColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildInfoCard(BuildContext context) {
  //   return ValueListenableBuilder(
  //     valueListenable: AppTextStyleNotifier.instance,
  //     builder: (context, _, __) {
  //       return Container(
  //         margin: const EdgeInsets.symmetric(horizontal: 16),
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: AppPalette.greyColor.withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(
  //             color: AppPalette.greyColor.withValues(alpha: 0.2),
  //             width: 1,
  //           ),
  //         ),
  //         child: Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: AppPalette.greyColor.withValues(alpha: 0.2),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Icon(
  //                 CupertinoIcons.info_circle_fill,
  //                 color: AppTextStyleNotifier.instance.textColor
  //                     .withValues(alpha: 0.7),
  //                 size: 24,
  //               ),
  //             ),
  //             const SizedBox(width: 16),
  //             Expanded(
  //               child: Text(
  //                 'You\'ll be notified when you exceed this time limit on any app',
  //                 style: GoogleFonts.getFont(
  //                   AppTextStyleNotifier.instance.fontFamily,
  //                   textStyle: TextStyle(
  //                     color: AppTextStyleNotifier.instance.textColor
  //                         .withValues(alpha: 0.85),
  //                     fontSize: 14,
  //                     height: 1.4,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildMonitoringToggle(BuildContext context) {
    return FutureBuilder<bool>(
      future: AppUsageService.isMonitoringRunning(),
      builder: (context, snapshot) {
        final isMonitoring = snapshot.data ?? false;

        return ValueListenableBuilder(
          valueListenable: AppTextStyleNotifier.instance,
          builder: (context, _, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppPalette.greyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppPalette.greyColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:  AppPalette.greyColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isMonitoring
                              ? CupertinoIcons.eye_solid
                              : CupertinoIcons.eye_slash,
                          color: 
                              AppTextStyleNotifier.instance.textColor
                                  .withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monitoring',
                            style: GoogleFonts.getFont(
                              AppTextStyleNotifier.instance.fontFamily,
                              textStyle: TextStyle(
                                color: AppTextStyleNotifier.instance.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            isMonitoring ? 'Active' : 'Stopped',
                            style: GoogleFonts.getFont(
                              AppTextStyleNotifier.instance.fontFamily,
                              textStyle: TextStyle(
                                color: isMonitoring
                                    ? AppPalette.blueColor
                                    : AppTextStyleNotifier.instance.textColor
                                        .withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch(
                    value: isMonitoring,
                    onChanged: (value) async {
                      if (value) {
                        // User wants to start - do nothing, they need to set time first
                        CustomSnackBar.show(
                          context,
                          message: 'Set time limit below and tap "Start Monitoring"',
                          backgroundColor: AppPalette.greyColor,
                          textAlign: TextAlign.center,
                        );
                      } else {
                        // User wants to stop
                        await _handleStopMonitoring(context);
                      }
                    },
                    activeColor: AppPalette.blueColor,
                    activeTrackColor:
                        AppPalette.blueColor.withValues(alpha: 0.5),
                    inactiveThumbColor: AppPalette.greyColor,
                    inactiveTrackColor:
                        AppPalette.greyColor.withValues(alpha: 0.3),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleStopMonitoring(BuildContext context) async {
    try {
      // Stop monitoring service
      await AppUsageService.stopMonitoring();

      // Save monitoring status
      await AppUsagePrefs().setMonitoringEnabled(false);

      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: '✓ Monitoring stopped',
          backgroundColor: AppPalette.greenColor,
          textAlign: TextAlign.center,
        );

        // Refresh the screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ScreenTimerScreen(),
          ),
        );
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

  Widget _buildSelectedTimeDisplay(BuildContext context) {
    return BlocBuilder<ScreenTimerCubit, ScreenTimerState>(
      builder: (context, state) {
        final totalMinutes = state.hours * 60 + state.minutes;
        final isValid = totalMinutes > 0;

        return ValueListenableBuilder(
          valueListenable: AppTextStyleNotifier.instance,
          builder: (context, _, __) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
        
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                       AppPalette.greyColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.timer,
                    color:  AppTextStyleNotifier.instance.textColor
                            .withValues(alpha: 0.5),
                    size: 40,
                  ),
                  const SizedBox(height: 12),
               
                  const SizedBox(height: 8),
                  Text(
                    '${state.hours}h ${state.minutes}m',
                    style: GoogleFonts.getFont(
                      AppTextStyleNotifier.instance.fontFamily,
                      textStyle: TextStyle(
                        color: AppTextStyleNotifier.instance.textColor,
                        fontSize: 42,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  if (!isValid) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Select at least 1 minute',
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: TextStyle(
                          color: AppPalette.redColor.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
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
        final totalMinutes = state.hours * 60 + state.minutes;
        final isValid = totalMinutes > 0;

        return ValueListenableBuilder(
          valueListenable: AppTextStyleNotifier.instance,
          builder: (context, _, __) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isValid
                      ? () async {
                          await _handleSetTimer(context, state);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValid
                        ? AppPalette.whiteColor
                        : AppPalette.greyColor.withValues(alpha: 0.3),
                    foregroundColor: isValid
                        ? AppPalette.blackColor
                        : AppPalette.whiteColor.withValues(alpha: 0.4),
                    disabledBackgroundColor:
                        AppPalette.greyColor.withValues(alpha: 0.2),
                    disabledForegroundColor:
                        AppPalette.whiteColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     
                  
                      Text(
                        'Start Monitoring',
                        style: GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
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
      final hasNotificationPermission =
          await AppUsageService.hasNotificationPermission();

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

      // 🎯 Load priority apps (user-selected apps)
      final priorityApps = await PriorityAppsPrefs().getPriorityApps();
      debugPrint('========================================');
      debugPrint('🎯 PRIORITY APPS DEBUG:');
      debugPrint('📱 Total priority apps: ${priorityApps.length}');
      debugPrint('📦 Priority apps list: $priorityApps');
      if (priorityApps.isEmpty) {
        debugPrint('⚠️ WARNING: No priority apps selected!');
      } else {
        for (var i = 0; i < priorityApps.length; i++) {
          debugPrint('  [$i] ${priorityApps[i]}');
        }
      }
      debugPrint('========================================');

      // Start monitoring service with priority apps filter
      await AppUsageService.startMonitoring(
        totalMinutes,
        priorityApps: priorityApps,
      );

      // Save monitoring status
      await AppUsagePrefs().setMonitoringEnabled(true);

      // Show success message
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message:
              '✓ Timer set for ${state.hours}h ${state.minutes}m. Monitoring started!',
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
    final title = isUsagePermission
        ? 'Usage Stats Permission'
        : 'Notification Permission';
    final icon = isUsagePermission
        ? CupertinoIcons.chart_bar_fill
        : CupertinoIcons.bell_fill;
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
            color: AppTextStyleNotifier.instance.textColor
                .withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppPalette.greyColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTextStyleNotifier.instance.textColor
                    .withValues(alpha: 0.8),
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
              color: AppTextStyleNotifier.instance.textColor
                  .withValues(alpha: 0.8),
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
                  color: AppTextStyleNotifier.instance.textColor
                      .withValues(alpha: 0.6),
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
                  final hasPermission =
                      await AppUsageService.hasUsagePermission();
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
                  final hasPermission =
                      await AppUsageService.hasNotificationPermission();
                  if (hasPermission) {
                    CustomSnackBar.show(
                      context,
                      message:
                          'Notification permission granted! Now set your timer.',
                      backgroundColor: AppPalette.greenColor,
                      textAlign: TextAlign.center,
                    );
                  } else {
                    CustomSnackBar.show(
                      context,
                      message:
                          'Notification permission denied. You won\'t receive alerts.',
                      backgroundColor: Colors.orange,
                      textAlign: TextAlign.center,
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.whiteColor,
              foregroundColor: AppPalette.blackColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Grant Permission',
              style: GoogleFonts.getFont(
                AppTextStyleNotifier.instance.fontFamily,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
