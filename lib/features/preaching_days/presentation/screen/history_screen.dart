import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/preaching_day_summary.dart';
import '../provider/preaching_days_provider.dart';
import '../widgets/journey_day_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Actualiza el provider con la fecha seleccionada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedDateProvider.notifier).state =
          _selectedDate;
    });

    final journeysAsync = ref.watch(journeysByDateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Historial',
            style: AppTextStyles.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => ref
                .read(preachingDaysNotifierProvider.notifier)
                .delete(''), // placeholder — sync en paso 10
            tooltip: 'Sincronizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Selector de fecha ──────────────────────────
          _DateNavigator(
            selectedDate: _selectedDate,
            onDateChanged: (d) =>
                setState(() => _selectedDate = d),
          ),

          // ── Filtro rápido por mes ──────────────────────
          _MonthStrip(
            selectedDate: _selectedDate,
            onMonthSelected: (d) =>
                setState(() => _selectedDate = d),
          ),

          const SizedBox(height: 8),

          // ── Lista de jornadas ──────────────────────────
          Expanded(
            child: journeysAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                  message: e.toString()),
              data: (journeys) {
                if (journeys.isEmpty) {
                  return _EmptyDay(date: _selectedDate);
                }
                return _JourneyList(
                  journeys: journeys,
                  onDelete: (id) =>
                      _confirmDelete(context, ref, id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar jornada'),
        content: const Text(
            '¿Seguro que deseas eliminar esta jornada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(preachingDaysNotifierProvider.notifier)
                  .delete(id);
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

// ── Navegador de fecha ────────────────────────────────────
class _DateNavigator extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateNavigator({
    required this.selectedDate,
    required this.onDateChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onDateChanged(picked);
  }

  bool get _isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _isToday
        ? 'Hoy'
        : DateFormat('EEEE d \'de\' MMMM', 'es')
        .format(selectedDate);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Día anterior
          _NavBtn(
            icon: Icons.chevron_left_rounded,
            onTap: () => onDateChanged(
                selectedDate.subtract(const Duration(days: 1))),
          ),
          const SizedBox(width: 8),

          // Fecha actual — toca para abrir picker
          Expanded(
            child: GestureDetector(
              onTap: () => _pickDate(context),
              child: Column(
                children: [
                  Text(
                    dateStr,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: _isToday
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('yyyy', 'es').format(selectedDate),
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),
          // Día siguiente (solo si no es hoy)
          _NavBtn(
            icon: Icons.chevron_right_rounded,
            onTap: _isToday
                ? null
                : () => onDateChanged(
                selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.divider,
          ),
        ),
        child: Icon(
          icon,
          color:
          enabled ? AppColors.primary : AppColors.textDisabled,
          size: 20,
        ),
      ),
    );
  }
}

// ── Strip de meses ────────────────────────────────────────
class _MonthStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onMonthSelected;

  const _MonthStrip({
    required this.selectedDate,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now    = DateTime.now();
    final months = List.generate(6, (i) {
      return DateTime(now.year, now.month - i, 1);
    }).reversed.toList();

    return Container(
      height: 48,
      color: AppColors.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        itemCount: months.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final month = months[i];
          final isSelected = month.year == selectedDate.year &&
              month.month == selectedDate.month;
          final label =
          DateFormat('MMM', 'es').format(month);

          return GestureDetector(
            onTap: () {
              // Si selecciona el mes actual, va a hoy
              final target = month.month == now.month &&
                  month.year == now.year
                  ? now
                  : month;
              onMonthSelected(target);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              ),
              child: Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Lista de jornadas ─────────────────────────────────────
class _JourneyList extends StatelessWidget {
  final List<PreachingDaySummaryModel> journeys;
  final ValueChanged<String> onDelete;

  const _JourneyList({
    required this.journeys,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: journeys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => JourneyDayCard(
        journey:  journeys[i],
        onDelete: () => onDelete(journeys[i].id),
      ),
    );
  }
}

// ── Estados ───────────────────────────────────────────────
class _EmptyDay extends StatelessWidget {
  final DateTime date;
  const _EmptyDay({required this.date});

  @override
  Widget build(BuildContext context) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_rounded,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text(
            isToday
                ? 'No hay jornadas hoy'
                : 'No hay jornadas en esta fecha',
            style: AppTextStyles.bodyMedium,
          ),
          if (isToday) ...[
            const SizedBox(height: 8),
            Text(
              'Usa el botón + para registrar una',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: AppTextStyles.bodyMedium),
    );
  }
}