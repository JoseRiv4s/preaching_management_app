import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/territory.dart';
import '../provider/territories_provider.dart';
import '../widgets/territory_form_sheet.dart';
import '../../../blocks/domain/model/block.dart';
import '../../../blocks/presentation/provider/blocks_provider.dart';
import '../../../blocks/presentation/screen/blocks_screen.dart';

class TerritoriesTab extends ConsumerWidget {
  const TerritoriesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(territoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Territorios', style: AppTextStyles.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () =>
                ref.read(territoriesProvider.notifier).sync(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref, null),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: switch (state) {
        AsyncLoading() =>
        const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => Center(
            child: Text(error.toString(),
                style: AppTextStyles.bodyMedium)),
        AsyncData(:final value) when value.isEmpty =>
            _EmptyView(onAdd: () => _showForm(context, ref, null)),
        AsyncData(:final value) => _TerritoryList(
          territories: value,
          onTap: (t) => _openBlocks(context, t),
          onEdit: (t) => _showForm(context, ref, t),
          onDelete: (t) => _confirmDelete(context, ref, t),
        ),
        _ => const SizedBox(),
      },
    );
  }

  void _showForm(BuildContext context, WidgetRef ref,
      Territory? territory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TerritoryFormSheet(territory: territory),
    );
  }

  void _openBlocks(BuildContext context, Territory territory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocksScreen(territory: territory),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Territory territory) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar territorio'),
        content: Text(
            '¿Seguro que deseas eliminar ${territory.name}?\n\n'
                'Se eliminarán todos sus bloques.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(territoriesProvider.notifier)
                  .delete(territory.id);
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

class _TerritoryList extends StatelessWidget {
  final List<Territory> territories;
  final ValueChanged<Territory> onTap;
  final ValueChanged<Territory> onEdit;
  final ValueChanged<Territory> onDelete;

  const _TerritoryList({
    required this.territories,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: territories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final t = territories[i];
        return _TerritoryCard(
          territory: t,
          onTap: () => onTap(t),
          onEdit: () => onEdit(t),
          onDelete: () => onDelete(t),
        );
      },
    );
  }
}

class _TerritoryCard extends ConsumerWidget {
  final Territory territory;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TerritoryCard({
    required this.territory,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha los bloques de este territorio en tiempo real
    final blocksAsync =
    ref.watch(blocksByTerritoryProvider(territory.id));

    final blocks     = blocksAsync.valueOrNull ?? [];
    final total      = blocks.length;
    final completed  = blocks.where((b) =>
    b.status == BlockStatus.completed).length;
    final progress   = total > 0 ? completed / total : 0.0;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(territory.name,
                            style: AppTextStyles.bodyLarge),
                        Text(
                          '$total bloques · $completed completados',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_rounded,
                            color: AppColors.primary, size: 18),
                        onPressed: onEdit,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 18),
                        onPressed: onDelete,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
              if (total > 0) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.divider,
                    color: AppColors.statusCompleted,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% completado',
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
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
          Icon(Icons.map_outlined,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('No hay territorios registrados',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar territorio'),
          ),
        ],
      ),
    );
  }
}