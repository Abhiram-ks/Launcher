import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';

class WeeklyBarChartWidget extends StatelessWidget {
  final List<String> days;
  final List<double> hours;
  final int selectedDayIndex;

  const WeeklyBarChartWidget({
    super.key,
    required this.days,
    required this.hours,
    this.selectedDayIndex = 1, // Default to Monday
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppTextStyleNotifier.instance,
      builder: (context, _, __) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppPalette.greyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppPalette.greyColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 8,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) =>
                      AppPalette.greyColor.withValues(alpha: 0.8),
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toStringAsFixed(1)} hrs',
                      GoogleFonts.getFont(
                        AppTextStyleNotifier.instance.fontFamily,
                        textStyle: const TextStyle(
                          color: AppPalette.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        final isSelected = value.toInt() == selectedDayIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt()],
                            style: GoogleFonts.getFont(
                              AppTextStyleNotifier.instance.fontFamily,
                              textStyle: TextStyle(
                                color: isSelected
                                    ? AppTextStyleNotifier.instance.textColor
                                    : AppTextStyleNotifier.instance.textColor
                                        .withValues(alpha: 0.5),
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppTextStyleNotifier.instance.textColor
                        .withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: _buildBarGroups(),
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(days.length, (index) {
      final isSelected = index == selectedDayIndex;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: hours[index],
            width: 24,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            gradient: LinearGradient(
              colors: isSelected
                  ? [
                      AppPalette.blueColor.withValues(alpha: 0.3),
                      AppPalette.blueColor,
                    ]
                  : [
                      AppTextStyleNotifier.instance.textColor
                          .withValues(alpha: 0.4),
                      AppTextStyleNotifier.instance.textColor
                          .withValues(alpha: 0.2),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
      );
    });
  }
}

