import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/service/app_usage_service.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/model/data/priority_apps_localdb.dart';
import 'package:minilauncher/features/view/widget/charts/weekly_bar_chart_widget.dart';
import 'package:minilauncher/features/view/widget/charts/weekly_line_chart_widget.dart';
import 'package:minilauncher/features/view/widget/date_picker_dialog_widget.dart';
import 'package:minilauncher/features/view_model/cubit/chart_view_cubit.dart';

class ScreenTimeActivity extends StatelessWidget {
  const ScreenTimeActivity({super.key});

  // Static day labels
  static const List<String> _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChartViewCubit(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Dashboard',
          isTitle: true,
        ),
        body: BlocBuilder<ChartViewCubit, ChartViewState>(
          builder: (context, chartState) {
            final selectedDate = chartState.selectedDate;
            final now = DateTime.now();

            // Load all data in ONE future to prevent caching issues
            return FutureBuilder<Map<String, dynamic>>(
              key: ValueKey('dashboard_${selectedDate.year}_${selectedDate.month}_${selectedDate.day}_${now.hour}'),
              future: _loadAllDashboardData(selectedDate, now),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppPalette.blueColor,
                    ),
                  );
                }

                final data = snapshot.data!;
                final priorityAppInfos = data['priorityAppInfos'] as List<AppInfo>;
                final weeklyHours = data['weeklyHours'] as List<double>;
                final selectedDayUsage = data['selectedDayUsage'] as Map<String, int>;
                final totalHours = data['totalHours'] as int;
                final totalMinutes = data['totalMinutes'] as int;
                final selectedDayIndex = data['selectedDayIndex'] as int;

                return _buildContent(
                  context,
                  priorityAppInfos,
                  selectedDayUsage,
                  totalHours,
                  totalMinutes,
                  weeklyHours,
                  selectedDayIndex,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<AppInfo> priorityAppInfos,
    Map<String, int> usageMap,
    int totalHours,
    int totalMinutes,
    List<double> weeklyHours,
    int selectedDayIndex,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ConstantWidgets.hight20(context),

          // View Selector Dropdown
          _buildViewSelector(context),

          ConstantWidgets.hight30(context),

          // Total Screen Time Display
          _buildTotalScreenTime(
            context,
            totalHours,
            totalMinutes,
          ),

          ConstantWidgets.hight30(context),

          // Chart (Bar or Line based on selection) with REAL weekly data
          BlocBuilder<ChartViewCubit, ChartViewState>(
            builder: (context, state) {
              return state.selectedView == 'Bar Chart'
                  ? WeeklyBarChartWidget(
                      days: _days,
                      hours: weeklyHours,
                      selectedDayIndex: selectedDayIndex,
                    )
                  : WeeklyLineChartWidget(
                      days: _days,
                      hours: weeklyHours,
                      selectedDayIndex: selectedDayIndex,
                    );
            },
          ),

          ConstantWidgets.hight30(context),

          // Date Navigation
          _buildDateNavigation(context),

          ConstantWidgets.hight20(context),

          // App Usage List
          _buildAppUsageListContent(
            context,
            priorityAppInfos,
            usageMap,
          ),

          ConstantWidgets.hight20(context),
        ],
      ),
    );
  }

  Widget _buildViewSelector(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BlocBuilder<ChartViewCubit, ChartViewState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      _showViewOptionsDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.greyColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppPalette.greyColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.selectedView,
                            style: GoogleFonts.getFont(
                              AppTextStyleNotifier.instance.fontFamily,
                              textStyle: TextStyle(
                                color: AppTextStyleNotifier.instance.textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTextStyleNotifier.instance.textColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showViewOptionsDialog(BuildContext context) {
    final cubit = context.read<ChartViewCubit>();
    final state = cubit.state;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppPalette.blackColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                AppTextStyleNotifier.instance.textColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        title: Text(
          'Select View',
          style: GoogleFonts.getFont(
            AppTextStyleNotifier.instance.fontFamily,
            textStyle: TextStyle(
              color: AppTextStyleNotifier.instance.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: state.viewOptions.map((option) {
            final isSelected = state.selectedView == option;
            return InkWell(
              onTap: () {
                cubit.selectView(option);
                Navigator.pop(dialogContext);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppPalette.blueColor.withValues(alpha: 0.2)
                      : AppPalette.greyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppPalette.blueColor
                        : AppPalette.greyColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppPalette.blueColor
                          : AppTextStyleNotifier.instance.textColor
                              .withValues(alpha: 0.5),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      option,
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: TextStyle(
                          color: AppTextStyleNotifier.instance.textColor,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
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
    );
  }

  Widget _buildTotalScreenTime(
    BuildContext context,
    int hours,
    int minutes,
  ) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return BlocBuilder<ChartViewCubit, ChartViewState>(
          builder: (context, state) {
            return Column(
              children: [
                Text(
                  '$hours hrs, $minutes mins',
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle: TextStyle(
                      color: AppTextStyleNotifier.instance.textColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.formattedDate,
                  style: GoogleFonts.getFont(
                    AppTextStyleNotifier.instance.fontFamily,
                    textStyle: TextStyle(
                      color: AppTextStyleNotifier.instance.textColor.withValues(
                        alpha: 0.6,
                      ),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateNavigation(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return BlocBuilder<ChartViewCubit, ChartViewState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Day Button
                  IconButton(
                    onPressed: () {
                      context.read<ChartViewCubit>().previousDay();
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppTextStyleNotifier.instance.textColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Date with Calendar Picker
                  GestureDetector(
                    onTap: () async {
                      final cubit = context.read<ChartViewCubit>();
                      final pickedDate = await DatePickerDialogWidget.show(
                        context: context,
                        initialDate: cubit.state.selectedDate,
                      );
                      if (pickedDate != null) {
                        cubit.selectDate(pickedDate);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                     
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppTextStyleNotifier.instance.textColor
                                .withValues(alpha: 0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.formattedDate,
                            style: GoogleFonts.getFont(
                              AppTextStyleNotifier.instance.fontFamily,
                              textStyle: TextStyle(
                                color: AppTextStyleNotifier.instance.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  // Next Day Button
                  IconButton(
                    onPressed: () {
                      context.read<ChartViewCubit>().nextDay();
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: AppTextStyleNotifier.instance.textColor,
                      size: 18,
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

  Widget _buildAppUsageListContent(
    BuildContext context,
    List<AppInfo> priorityAppInfos,
    Map<String, int> usageMap,
  ) {
    if (priorityAppInfos.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort apps by usage time (highest first)
    final sortedApps = List<AppInfo>.from(priorityAppInfos);
    sortedApps.sort((a, b) {
      final usageA = usageMap[a.packageName] ?? 0;
      final usageB = usageMap[b.packageName] ?? 0;
      return usageB.compareTo(usageA);
    });

    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sortedApps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final app = sortedApps[index];
            final usageMinutes = usageMap[app.packageName] ?? 0;
            return _buildAppUsageItemDynamic(context, app, usageMinutes);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppPalette.greyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppPalette.greyColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.app_settings_alt,
                size: 64,
                color: AppTextStyleNotifier.instance.textColor
                    .withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Apps Added',
                style: GoogleFonts.getFont(
                  AppTextStyleNotifier.instance.fontFamily,
                  textStyle: TextStyle(
                    color: AppTextStyleNotifier.instance.textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add apps to your home screen to see their screen time here',
                textAlign: TextAlign.center,
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
        );
      },
    );
  }

  Widget _buildAppUsageItemDynamic(
    BuildContext context,
    AppInfo app,
    int usageMinutes,
  ) {
    // Format real usage time
    final hours = usageMinutes ~/ 60;
    final mins = usageMinutes % 60;
    
    final usageText = usageMinutes == 0
        ? 'No usage'
        : hours > 0
            ? '$hours hr${hours > 1 ? 's' : ''}, $mins mins'
            : '$mins mins';

    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppPalette.greyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppPalette.greyColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Real App Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: app.icon != null
                    ? Image.memory(
                        app.icon!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultIcon();
                        },
                      )
                    : _buildDefaultIcon(),
              ),
              const SizedBox(width: 16),

              // App Name and Usage Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: TextStyle(
                          color: AppTextStyleNotifier.instance.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usageText,
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
              ),

              // Timer Icon
              Icon(
                CupertinoIcons.hourglass,
                color: AppTextStyleNotifier.instance.textColor.withValues(
                  alpha: 0.5,
                ),
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppPalette.greyColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.apps,
        color: AppPalette.whiteColor,
        size: 28,
      ),
    );
  }

  /// Load ALL dashboard data in one future to prevent caching issues
  Future<Map<String, dynamic>> _loadAllDashboardData(
    DateTime selectedDate,
    DateTime now,
  ) async {
    // Load priority apps
    final priorityApps = await PriorityAppsPrefs().getPriorityApps();
    
    // Load installed apps
    final installedApps = await InstalledApps.getInstalledApps(
      excludeSystemApps: false,
      withIcon: true,
    );
    
    // Filter to show only priority apps
    final priorityAppInfos = installedApps
        .where((app) => priorityApps.contains(app.packageName))
        .toList();
    
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📱 Priority apps: ${priorityApps.length} | Found: ${priorityAppInfos.length}');
    debugPrint('📋 Apps: ${priorityAppInfos.map((a) => a.name).join(", ")}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // Load weekly usage data
    final weeklyData = await _loadWeeklyUsageData(
      priorityApps,
      selectedDate,
      now,
    );
    
    final weeklyHours = weeklyData['weeklyHours'] as List<double>;
    final selectedDayUsage = weeklyData['selectedDayUsage'] as Map<String, int>;
    final totalMinutes = weeklyData['totalMinutes'] as int;
    
    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;
    final selectedDayIndex = selectedDate.weekday % 7;
    
    debugPrint('🎯 FINAL DATA BEING SENT TO UI:');
    debugPrint('   Total: $totalHours hrs, $remainingMinutes mins');
    debugPrint('   Selected day usage map:');
    selectedDayUsage.forEach((pkg, mins) {
      final appName = priorityAppInfos.firstWhere((a) => a.packageName == pkg, orElse: () => priorityAppInfos.first).name;
      debugPrint('      $appName: $mins mins');
    });
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    return {
      'priorityAppInfos': priorityAppInfos,
      'weeklyHours': weeklyHours,
      'selectedDayUsage': selectedDayUsage,
      'totalHours': totalHours,
      'totalMinutes': remainingMinutes,
      'selectedDayIndex': selectedDayIndex,
    };
  }

  /// Load usage data for the entire week with accurate per-day breakdown
  Future<Map<String, dynamic>> _loadWeeklyUsageData(
    List<String> priorityApps,
    DateTime selectedDay,
    DateTime now,
  ) async {
    final today = DateTime(now.year, now.month, now.day);
    
    // Normalize selected day to remove time component
    final normalizedSelectedDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    
    // Start from Sunday of the week containing selected day
    final weekStart = normalizedSelectedDay.subtract(
      Duration(days: normalizedSelectedDay.weekday % 7),
    );

    debugPrint('🗓️ Normalized Selected Day: ${normalizedSelectedDay.toString().split(' ')[0]}');
    debugPrint('🗓️ Week Start (Sunday): ${weekStart.toString().split(' ')[0]}');

    final weeklyHours = <double>[];
    Map<String, int> selectedDayUsage = {};
    int selectedDayTotalMinutes = 0;

    // Make 7 separate calls for accurate per-day data
    for (int i = 0; i < 7; i++) {
      final dayStart = weekStart.add(Duration(days: i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      // Check if this day is today
      final isToday = dayStart.year == today.year &&
          dayStart.month == today.month &&
          dayStart.day == today.day;
      
      // Check if this day is in the FUTURE
      final isFuture = dayStart.isAfter(today);

      // Skip future days - show 0 usage
      if (isFuture) {
        weeklyHours.add(0.0);
        debugPrint('⏭️ Day $i (${_days[i]}): Future day, skipping');
        continue;
      }

      try {
        // For today: use NOW, for past: use end of day
        final actualDayEnd = isToday ? now : dayEnd;
        
        // Get usage for this specific day
        final dayUsageData = await AppUsageService.getAppUsage(
          dayStart,
          actualDayEnd,
        );

        // Sum usage for priority apps only
        int dayMinutes = 0;
        final dayPriorityUsage = <String, int>{};
        
        for (var usage in dayUsageData) {
          if (priorityApps.contains(usage.packageName)) {
            dayMinutes += usage.usageTimeMinutes;
            dayPriorityUsage[usage.packageName] = usage.usageTimeMinutes;
          }
        }

        // Convert to hours for chart
        weeklyHours.add(dayMinutes / 60.0);
        
        debugPrint('📊 Day $i (${_days[i]}): $dayMinutes mins = ${(dayMinutes / 60.0).toStringAsFixed(1)} hrs');

        // If this is the selected day, save the detailed usage
        final isSameDay = dayStart.year == normalizedSelectedDay.year &&
            dayStart.month == normalizedSelectedDay.month &&
            dayStart.day == normalizedSelectedDay.day;

        debugPrint('🔍 Comparing: dayStart=${dayStart.toString().split(' ')[0]} vs selected=${normalizedSelectedDay.toString().split(' ')[0]} → match=$isSameDay');

        if (isSameDay) {
          debugPrint('━━━━━━━ SELECTED DAY DETAILS ━━━━━━━');
          debugPrint('✅ SELECTED DAY MATCHED: ${_days[i]} (${dayStart.toString().split(' ')[0]})');
          
          selectedDayUsage = dayPriorityUsage;
          selectedDayTotalMinutes = dayMinutes;
          
          debugPrint('📱 Priority apps with usage for THIS specific day:');
          for (var pkg in priorityApps) {
            final mins = dayPriorityUsage[pkg] ?? 0;
            debugPrint('   $pkg: $mins mins');
          }
          debugPrint('📊 Total from sum: $selectedDayTotalMinutes mins (${(selectedDayTotalMinutes / 60.0).toStringAsFixed(1)} hrs)');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        }
      } catch (e) {
        debugPrint('❌ Error loading day $i: $e');
        weeklyHours.add(0.0);
      }
    }

    debugPrint('📈 Final weekly hours: $weeklyHours');

    return {
      'weeklyHours': weeklyHours,
      'selectedDayUsage': selectedDayUsage,
      'totalMinutes': selectedDayTotalMinutes,
    };
  }
}
