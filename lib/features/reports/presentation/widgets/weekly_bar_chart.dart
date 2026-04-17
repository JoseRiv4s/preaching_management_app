import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/report_data.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<WeekActivity> weeklyActivity;

  const WeeklyBarChart({super.key, required this.weeklyActivity});

  @override
  Widget build(BuildContext context) {
    final maxY = weeklyActivity
        .map((w) => w.journeyCount.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxY < 1 ? 4 : maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final week = value.toInt() + 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Sem $week',
                      style: AppTextStyles.caption,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: weeklyActivity.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.journeyCount.toDouble(),
                  color: AppColors.primary,
                  width: 28,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY < 1 ? 4 : maxY + 1,
                    color: AppColors.primary.withOpacity(0.06),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
