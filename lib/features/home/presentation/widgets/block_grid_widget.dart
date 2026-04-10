import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/territory_summary.dart';

class BlockGridWidget extends StatelessWidget {
  final List<BlockSummary> blocks;

  const BlockGridWidget({super.key, required this.blocks});

  Color _colorForStatus(BlockStatus status) => switch (status) {
        BlockStatus.completed  => AppColors.statusCompleted,
        BlockStatus.inProgress => AppColors.statusInProgress,
        BlockStatus.pending    => AppColors.statusPending,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final block = blocks[index];
            return _BlockCell(block: block, color: _colorForStatus(block.status));
          },
        ),
        // Leyenda
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.statusCompleted,  label: 'Completado'),
              const SizedBox(width: 12),
              _LegendItem(color: AppColors.statusInProgress, label: 'En progreso'),
              const SizedBox(width: 12),
              _LegendItem(color: AppColors.statusPending,    label: 'Pendiente'),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlockCell extends StatelessWidget {
  final BlockSummary block;
  final Color color;

  const _BlockCell({required this.block, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Text(
          block.blockNumber,
          style: AppTextStyles.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}