import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/captain.dart';
import '../provider/captains_provider.dart';
import '../widgets/captain_form_sheet.dart';

class CaptainsScreen extends ConsumerWidget {
  final String search;
  const CaptainsScreen({super.key, this.search = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captainsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: switch (state) {
        AsyncLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        AsyncError(:final error) => _ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(captainsProvider.notifier).sync(),
        ),
        AsyncData(:final value) when value.isEmpty =>
        const _EmptyView(),
        AsyncData(:final value) => _CaptainList(
          captains: value
              .where((c) =>
              c.name.toLowerCase().contains(search.toLowerCase()))
              .toList(),
          onEdit: (c) => _showForm(context, ref, c),
          onDelete: (c) => _confirmDelete(context, ref, c),
        ),
        _ => const SizedBox(),
      },
    );
  }

  void _showForm(BuildContext context, WidgetRef ref,
      Captain? captain) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CaptainFormSheet(captain: captain),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Captain captain) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar capitán'),
        content:
        Text('¿Seguro que deseas eliminar a ${captain.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(captainsProvider.notifier)
                  .delete(captain.id);
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

// ── Lista ────────────────────────────────────────────────
class _CaptainList extends StatelessWidget {
  final List<Captain> captains;
  final ValueChanged<Captain> onEdit;
  final ValueChanged<Captain> onDelete;

  const _CaptainList({
    required this.captains,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: captains.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final c = captains[index];
        return _CaptainCard(
          captain: c,
          onEdit: () => onEdit(c),
          onDelete: () => onDelete(c),
        );
      },
    );
  }
}

// ── Card ─────────────────────────────────────────────────
class _CaptainCard extends StatelessWidget {
  final Captain captain;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CaptainCard({
    required this.captain,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.accent.withOpacity(0.15),
          child: Text(
            captain.name[0].toUpperCase(),
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(captain.name,
                  style: AppTextStyles.bodyLarge),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (captain.phone != null)
              Text(captain.phone!,
                  style: AppTextStyles.bodyMedium),
            if (captain.email != null)
              Text(captain.email!,
                  style: AppTextStyles.bodyMedium),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Estados vacío y error ────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.manage_accounts_outlined,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('No hay capitanes registrados',
              style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}