import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CoverageDonutChart extends StatelessWidget {
  final double coverage; // 0.0 - 1.0
  final String label;

  const CoverageDonutChart({
    super.key,
    required this.coverage,
    required this.label,
  });

  Color get _color {
    if (coverage >= 0.75) return AppColors.statusCompleted;
    if (coverage >= 0.40) return AppColors.statusInProgress;
    return AppColors.statusPending;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (coverage * 100).toStringAsFixed(0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sectionsSpace: 0,
                  centerSpaceRadius: 38,
                  sections: [
                    PieChartSectionData(
                      value: coverage * 100,
                      color: _color,
                      radius: 16,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: (1 - coverage) * 100,
                      color: AppColors.divider,
                      radius: 14,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
              // Texto central
              Text(
                '$percent%',
                style: AppTextStyles.headingMedium.copyWith(
                  color: _color,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
