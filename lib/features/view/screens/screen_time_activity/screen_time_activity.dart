import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
import 'package:minilauncher/features/model/data/priority_apps_localdb.dart';
import 'package:minilauncher/features/view/widget/charts/weekly_bar_chart_widget.dart';
import 'package:minilauncher/features/view/widget/charts/weekly_line_chart_widget.dart';
import 'package:minilauncher/features/view/widget/date_picker_dialog_widget.dart';
import 'package:minilauncher/features/view_model/cubit/chart_view_cubit.dart';

class ScreenTimeActivity extends StatelessWidget {
  const ScreenTimeActivity({super.key});

  // Static data for charts
  static const List<String> _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const List<double> _hours = [2.5, 6.5, 4.0, 3.5, 5.0, 4.5, 3.0];
  static const int _selectedDayIndex = 1; // Monday

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChartViewCubit(),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Dashboard',
          isTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ConstantWidgets.hight20(context),

              // View Selector Dropdown
              _buildViewSelector(context),

              ConstantWidgets.hight30(context),

              // Total Screen Time Display
              _buildTotalScreenTime(context),

              ConstantWidgets.hight30(context),

              // Chart (Bar or Line based on selection)
              BlocBuilder<ChartViewCubit, ChartViewState>(
                builder: (context, state) {
                  return state.selectedView == 'Bar Chart'
                      ? const WeeklyBarChartWidget(
                          days: _days,
                          hours: _hours,
                          selectedDayIndex: _selectedDayIndex,
                        )
                      : const WeeklyLineChartWidget(
                          days: _days,
                          hours: _hours,
                          selectedDayIndex: _selectedDayIndex,
                        );
                },
              ),

              ConstantWidgets.hight30(context),

              // Date Navigation
              _buildDateNavigation(context),

              ConstantWidgets.hight20(context),

              // App Usage List
              _buildAppUsageList(context),

              ConstantWidgets.hight20(context),
            ],
          ),
        ),
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

  Widget _buildTotalScreenTime(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return BlocBuilder<ChartViewCubit, ChartViewState>(
          builder: (context, state) {
            return Column(
              children: [
                Text(
                  '6 hrs, 20 mins',
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

  Widget _buildAppUsageList(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: PriorityAppsPrefs().getPriorityApps(),
      builder: (context, prioritySnapshot) {
        if (!prioritySnapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: AppPalette.blueColor,
              ),
            ),
          );
        }

        final priorityApps = prioritySnapshot.data!;

        if (priorityApps.isEmpty) {
          return _buildEmptyState(context);
        }

        // Load all installed apps to get real app info
        return FutureBuilder<List<AppInfo>>(
          future: InstalledApps.getInstalledApps(
            excludeSystemApps: false,
            withIcon: true,
          ),
          builder: (context, appsSnapshot) {
            if (!appsSnapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(
                    color: AppPalette.blueColor,
                  ),
                ),
              );
            }

            final installedApps = appsSnapshot.data!;

            // Debug logging
            debugPrint('📱 Priority apps from storage: ${priorityApps.length} apps');
            debugPrint('📦 Priority packages: $priorityApps');
            debugPrint('📲 Total installed apps loaded: ${installedApps.length}');

            // Filter to show only priority apps
            final priorityAppInfos = installedApps
                .where((app) => priorityApps.contains(app.packageName))
                .toList();

            debugPrint('✅ Filtered priority app infos: ${priorityAppInfos.length} apps');
            debugPrint('📋 Showing apps: ${priorityAppInfos.map((a) => a.name).join(", ")}');

            if (priorityAppInfos.isEmpty) {
              return _buildEmptyState(context);
            }

            return ValueListenableBuilder(
              valueListenable: AppTextStyleNotifier.instance,
              builder: (context, _, __) {
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: priorityAppInfos.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final app = priorityAppInfos[index];
                    return _buildAppUsageItemDynamic(context, app);
                  },
                );
              },
            );
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

  Widget _buildAppUsageItemDynamic(BuildContext context, AppInfo app) {
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
                      '3 hrs, 20 mins', // Static for now
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
}
