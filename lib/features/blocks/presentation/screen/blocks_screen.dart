import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../territories/domain/model/territory.dart';
import '../../domain/model/block.dart';
import '../provider/blocks_provider.dart';
import '../widgets/block_form_sheet.dart';
import '../widgets/block_status_chip.dart';

class BlocksScreen extends ConsumerWidget {
  final Territory territory;
  const BlocksScreen({super.key, required this.territory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync =
    ref.watch(blocksByTerritoryProvider(territory.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(territory.name, style: AppTextStyles.headingSmall),
            Text('Bloques de predicación',
                style: AppTextStyles.caption),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () =>
                ref.read(blocksProvider.notifier).sync(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref, null),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: blocksAsync.when(
        loading: () =>
        const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(e.toString())),
        data: (blocks) {
          if (blocks.isEmpty) {
            return _EmptyView(
                onAdd: () => _showForm(context, ref, null));
          }
          return Column(
            children: [
              // Stats bar
              _StatsBar(blocks: blocks),
              // Grid de bloques
              Expanded(
                child: _BlockGrid(
                  blocks: blocks,
                  onTap: (b) => _showStatusPicker(context, ref, b),
                  onEdit: (b) => _showForm(context, ref, b),
                  onDelete: (b) =>
                      _confirmDelete(context, ref, b),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, Block? block) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlockFormSheet(
        block: block,
        territoryId: territory.id,
      ),
    );
  }

  void _showStatusPicker(
      BuildContext context, WidgetRef ref, Block block) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusPickerSheet(
        block: block,
        onSelect: (status) {
          ref.read(blocksProvider.notifier).updateBlock(
            block.copyWith(status: status),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Block block) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar bloque'),
        content: Text(
            '¿Eliminar el bloque ${block.blockNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(blocksProvider.notifier).delete(block);
            },
            style: TextButton.styleFrom(
                foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ── Stats ─────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final List<Block> blocks;
  const _StatsBar({required this.blocks});

  @override
  Widget build(BuildContext context) {
    final total    = blocks.length;
    final completed = blocks
        .where((b) => b.status == BlockStatus.completed).length;
    final inProgress = blocks
        .where((b) => b.status == BlockStatus.inProgress).length;
    final pending  = blocks
        .where((b) => b.status == BlockStatus.pending).length;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          _StatItem(label: 'Total',    value: '$total',
              color: AppColors.primary),
          _StatItem(label: 'Completados', value: '$completed',
              color: AppColors.statusCompleted),
          _StatItem(label: 'En progreso', value: '$inProgress',
              color: AppColors.statusInProgress),
          _StatItem(label: 'Pendientes', value: '$pending',
              color: AppColors.statusPending),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headingSmall
                  .copyWith(color: color)),
          Text(label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Grid de bloques ───────────────────────────────────────
class _BlockGrid extends StatelessWidget {
  final List<Block> blocks;
  final ValueChanged<Block> onTap;
  final ValueChanged<Block> onEdit;
  final ValueChanged<Block> onDelete;

  const _BlockGrid({
    required this.blocks,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _color(BlockStatus s) => switch (s) {
    BlockStatus.completed  => AppColors.statusCompleted,
    BlockStatus.inProgress => AppColors.statusInProgress,
    BlockStatus.pending    => AppColors.statusPending,
  };

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: blocks.length,
      itemBuilder: (_, i) {
        final b = blocks[i];
        final color = _color(b.status);
        return GestureDetector(
          onTap: () => onTap(b),
          onLongPress: () => _showOptions(context, b),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Center(
              child: Text(
                b.blockNumber,
                style: AppTextStyles.labelMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOptions(BuildContext context, Block block) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_rounded,
                  color: AppColors.primary),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                onEdit(block);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(context);
                onDelete(block);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Picker ─────────────────────────────────────────
class _StatusPickerSheet extends StatelessWidget {
  final Block block;
  final ValueChanged<BlockStatus> onSelect;

  const _StatusPickerSheet({
    required this.block,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bloque ${block.blockNumber}',
              style: AppTextStyles.headingSmall),
          Text('Cambiar estado',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          ...BlockStatus.values.map((s) {
            final isSelected = block.status == s;
            final color = switch (s) {
              BlockStatus.completed  => AppColors.statusCompleted,
              BlockStatus.inProgress => AppColors.statusInProgress,
              BlockStatus.pending    => AppColors.statusPending,
            };
            return ListTile(
              leading: Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(s.label),
              trailing: isSelected
                  ? Icon(Icons.check_rounded,
                  color: AppColors.primary)
                  : null,
              onTap: () {
                Navigator.pop(context);
                onSelect(s);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_view_rounded,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('No hay bloques en este territorio',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar bloque'),
          ),
        ],
      ),
    );
  }
}