import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/block.dart';

class BlockStatusChip extends StatelessWidget {
  final BlockStatus status;
  const BlockStatusChip({super.key, required this.status});

  Color get _color => switch (status) {
    BlockStatus.completed  => AppColors.statusCompleted,
    BlockStatus.inProgress => AppColors.statusInProgress,
    BlockStatus.pending    => AppColors.statusPending,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}