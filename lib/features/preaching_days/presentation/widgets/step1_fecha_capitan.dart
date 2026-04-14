import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../captains/presentation/provider/captains_provider.dart';
import '../../../captains/domain/model/captain.dart';
import '../provider/nueva_salida_form_provider.dart';

class Step1FechaCapitan extends ConsumerWidget {
  const Step1FechaCapitan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form    = ref.watch(nuevaSalidaFormProvider);
    final notifier = ref.read(nuevaSalidaFormProvider.notifier);
    final captainsState = ref.watch(captainsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fecha ──────────────────────────────────────
          Text('Fecha de la jornada',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          _DateSelector(
            selectedDate: form.date,
            onDateChanged: notifier.setDate,
          ),

          const SizedBox(height: 24),

          // ── Capitán ────────────────────────────────────
          Text('Seleccionar capitán',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: 4),
          Text(
            'El capitán liderará esta jornada',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),

          captainsState.when(
            loading: () => const Center(
                child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString()),
            data: (captains) {
              if (captains.isEmpty) {
                return _NoCaptainsWarning();
              }
              return _CaptainSelector(
                captains:         captains,
                selectedCaptain:  form.captain,
                onSelect:         notifier.setCaptain,
              );
            },
          ),

          // ── Notas ──────────────────────────────────────
          const SizedBox(height: 24),
          Text('Notas (opcional)',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: form.notes,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Observaciones de la jornada...',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
            onChanged: notifier.setNotes,
          ),
        ],
      ),
    );
  }
}

// ── Selector de fecha ─────────────────────────────────────
class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
    DateFormat('EEEE, d \'de\' MMMM yyyy', 'es')
        .format(selectedDate);

    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fecha seleccionada',
                      style: AppTextStyles.caption),
                  Text(dateStr,
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar_rounded,
                color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Selector de capitán ───────────────────────────────────
class _CaptainSelector extends StatelessWidget {
  final List<Captain> captains;
  final Captain? selectedCaptain;
  final ValueChanged<Captain> onSelect;

  const _CaptainSelector({
    required this.captains,
    required this.selectedCaptain,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: captains.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final captain    = captains[i];
        final isSelected = selectedCaptain?.id == captain.id;

        return GestureDetector(
          onTap: () => onSelect(captain),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.1),
                  child: Text(
                    captain.name[0].toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(captain.name,
                          style: AppTextStyles.bodyLarge),
                      if (captain.phone != null)
                        Text(captain.phone!,
                            style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoCaptainsWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No hay capitanes registrados. Ve a Grupo → Capitanes para agregar uno.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}