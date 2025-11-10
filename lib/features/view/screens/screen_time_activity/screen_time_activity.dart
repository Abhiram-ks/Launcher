import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/common/custom_appbar.dart';
import 'package:minilauncher/core/constant/constant.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';
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
    final apps = [
      const _AppUsageData(
        appName: 'Instagram',
        packageName: 'com.instagram.android',
        usageTime: '3 hrs, 20 mins',
        iconColor: Colors.pink,
        icon: Icons.camera_alt,
      ),
      const _AppUsageData(
        appName: 'WhatsApp',
        packageName: 'com.whatsapp',
        usageTime: '1 hr, 37 mins',
        iconColor: Colors.green,
        icon: Icons.chat,
      ),
      const _AppUsageData(
        appName: 'YouTube',
        packageName: 'com.google.android.youtube',
        usageTime: '1 hr, 23 mins',
        iconColor: Colors.red,
        icon: Icons.play_arrow,
      ),
      const _AppUsageData(
        appName: 'Chrome',
        packageName: 'com.android.chrome',
        usageTime: '45 mins',
        iconColor: Colors.blue,
        icon: Icons.language,
      ),
      const _AppUsageData(
        appName: 'Gmail',
        packageName: 'com.google.android.gm',
        usageTime: '30 mins',
        iconColor: Colors.red,
        icon: Icons.email,
      ),
    ];

    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: apps.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final app = apps[index];
            return _buildAppUsageItem(context, app);
          },
        );
      },
    );
  }

  Widget _buildAppUsageItem(BuildContext context, _AppUsageData app) {
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
              // App Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: app.iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(app.icon, color: app.iconColor, size: 28),
              ),
              const SizedBox(width: 16),

              // App Name and Usage Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appName,
                      style: GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: TextStyle(
                          color: AppTextStyleNotifier.instance.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.usageTime,
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
}

// Static Data Model
class _AppUsageData {
  final String appName;
  final String packageName;
  final String usageTime;
  final Color iconColor;
  final IconData icon;

  const _AppUsageData({
    required this.appName,
    required this.packageName,
    required this.usageTime,
    required this.iconColor,
    required this.icon,
  });
}
