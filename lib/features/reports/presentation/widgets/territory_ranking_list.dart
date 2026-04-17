import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/report_data.dart';

class TerritoryRankingList extends StatelessWidget {
  final List<TerritoryRanking> rankings;

  const TerritoryRankingList({super.key, required this.rankings});

  Color _coverageColor(double coverage) {
    if (coverage >= 0.75) return AppColors.statusCompleted;
    if (coverage >= 0.40) return AppColors.statusInProgress;
    return AppColors.statusPending;
  }

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Sin datos de territorios',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const SizedBox(width: 36),
              Expanded(
                child: Text('Territorio', style: AppTextStyles.labelMedium),
              ),
              Text('Cobertura', style: AppTextStyles.labelMedium),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 8),

        // Lista
        ...rankings.take(5).map((r) => _RankingItem(
              ranking: r,
              coverageColor: _coverageColor(r.coverage),
            )),
      ],
    );
  }
}

class _RankingItem extends StatelessWidget {
  final TerritoryRanking ranking;
  final Color coverageColor;

  const _RankingItem({
    required this.ranking,
    required this.coverageColor,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (ranking.coverage * 100).toStringAsFixed(0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Número de ranking
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: ranking.rank == 1
                  ? AppColors.statusCompleted
                  : ranking.rank == 2
                      ? AppColors.statusInProgress
                      : ranking.rank <= 3
                          ? AppColors.statusPending
                          : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${ranking.rank}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Ícono de mapa
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: coverageColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.map_rounded, size: 16, color: coverageColor),
          ),
          const SizedBox(width: 10),

          // Nombre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.territoryName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${ranking.completedBlocks}/'
                  '${ranking.totalBlocks} bloques',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Barra de progreso + %
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: coverageColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        size: 12, color: coverageColor),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ranking.coverage,
                    backgroundColor: coverageColor.withOpacity(0.15),
                    color: coverageColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
