import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minilauncher/core/service/app_text_style_notifier.dart';
import 'package:minilauncher/core/themes/app_colors.dart';

class WeeklyLineChartWidget extends StatelessWidget {
  final List<String> days;
  final List<double> hours;
  final int selectedDayIndex;

  const WeeklyLineChartWidget({
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
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: false,
                verticalInterval: 1,
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: AppTextStyleNotifier.instance.textColor
                        .withValues(alpha: 0.1),
                    strokeWidth: 1,
                  );
                },
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
                    interval: 1,
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
              minX: 0,
              maxX: (days.length - 1).toDouble(),
              minY: 0,
              maxY: 8,
              lineBarsData: [
                LineChartBarData(
                  spots: _buildSpots(),
                  isCurved: true,
                  color: AppPalette.blueColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppPalette.blueColor.withValues(alpha: 0.3),
                        AppPalette.blueColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) =>
                      AppPalette.greyColor.withValues(alpha: 0.8),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      return LineTooltipItem(
                        '${barSpot.y.toStringAsFixed(1)} hrs',
                        GoogleFonts.getFont(
                          AppTextStyleNotifier.instance.fontFamily,
                          textStyle: const TextStyle(
                            color: AppPalette.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _buildSpots() {
    return List.generate(
      hours.length,
      (index) => FlSpot(index.toDouble(), hours[index]),
    );
  }
}

