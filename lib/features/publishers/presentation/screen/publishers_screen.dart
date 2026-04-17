import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/publisher.dart';
import '../provider/publishers_provider.dart';
import '../widgets/publisher_form_sheet.dart';

class PublishersScreen extends ConsumerWidget {
  final String search;
  const PublishersScreen({super.key, this.search = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(publishersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: switch (state) {
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        AsyncError(:final error) => _ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(publishersProvider.notifier).sync(),
        ),
        AsyncData(:final value) => _PublisherList(
          publishers: value
              .where((p) =>
              p.name.toLowerCase().contains(search.toLowerCase()))
              .toList(),
          onEdit: (p) => _showForm(context, ref, p),
          onDelete: (p) => _confirmDelete(context, ref, p),
        ),
        _ => const SizedBox(),
      },
    );
  }

  void _showForm(BuildContext context, WidgetRef ref,
      Publisher? publisher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PublisherFormSheet(publisher: publisher),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, Publisher publisher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar publisher'),
        content: Text(
            '¿Seguro que deseas eliminar a ${publisher.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(publishersProvider.notifier)
                  .delete(publisher.id);
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
class _PublisherList extends StatelessWidget {
  final List<Publisher> publishers;
  final ValueChanged<Publisher> onEdit;
  final ValueChanged<Publisher> onDelete;

  const _PublisherList({
    required this.publishers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: publishers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final p = publishers[index];
        return _PublisherCard(
          publisher: p,
          onEdit: () => onEdit(p),
          onDelete: () => onDelete(p),
        );
      },
    );
  }
}

// ── Card ─────────────────────────────────────────────────
class _PublisherCard extends StatelessWidget {
  final Publisher publisher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PublisherCard({
    required this.publisher,
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
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            publisher.name[0].toUpperCase(),
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(publisher.name, style: AppTextStyles.bodyLarge),
        subtitle: publisher.phone != null
            ? Text(publisher.phone!, style: AppTextStyles.bodyMedium)
            : null,
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
          Icon(Icons.group_outlined,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            'No hay publicadores registrados',
            style: AppTextStyles.bodyMedium,
          ),
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