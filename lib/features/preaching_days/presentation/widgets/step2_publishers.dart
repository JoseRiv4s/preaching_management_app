import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../publishers/domain/model/publisher.dart';
import '../../../publishers/presentation/provider/publishers_provider.dart';
import '../provider/nueva_salida_form_provider.dart';

class Step2Publishers extends ConsumerStatefulWidget {
  const Step2Publishers({super.key});

  @override
  ConsumerState<Step2Publishers> createState() =>
      _Step2PublishersState();
}

class _Step2PublishersState extends ConsumerState<Step2Publishers> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final form       = ref.watch(nuevaSalidaFormProvider);
    final notifier   = ref.read(nuevaSalidaFormProvider.notifier);
    final pubState   = ref.watch(publishersProvider);

    return Column(
      children: [
        // Header con contador
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Selecciona los participantes',
                  style: AppTextStyles.headingSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: form.selectedPublishers.isNotEmpty
                      ? AppColors.primary
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${form.selectedPublishers.length} seleccionados',
                  style: AppTextStyles.caption.copyWith(
                    color: form.selectedPublishers.isNotEmpty
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Buscador
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar publisher...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () =>
                    setState(() => _search = ''),
              )
                  : null,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),

        // Lista
        Expanded(
          child: pubState.when(
            loading: () => const Center(
                child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(e.toString())),
            data: (publishers) {
              final filtered = publishers
                  .where((p) => p.name
                  .toLowerCase()
                  .contains(_search.toLowerCase()))
                  .toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text('No se encontraron publishers',
                      style: AppTextStyles.bodyMedium),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = filtered[i];
                  final isSelected =
                  form.selectedPublishers.contains(p);

                  return _PublisherSelectItem(
                    publisher:  p,
                    isSelected: isSelected,
                    onTap:      () => notifier.togglePublisher(p),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PublisherSelectItem extends StatelessWidget {
  final Publisher publisher;
  final bool isSelected;
  final VoidCallback onTap;

  const _PublisherSelectItem({
    required this.publisher,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
            isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.1),
              child: Text(
                publisher.name[0].toUpperCase(),
                style: TextStyle(
                  color:
                  isSelected ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(publisher.name,
                      style: AppTextStyles.bodyLarge),
                  if (publisher.phone != null)
                    Text(publisher.phone!,
                        style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, key: ValueKey(true))
                  : const Icon(Icons.radio_button_unchecked_rounded,
                  color: AppColors.textDisabled,
                  key: ValueKey(false)),
            ),
          ],
        ),
      ),
    );
  }
}