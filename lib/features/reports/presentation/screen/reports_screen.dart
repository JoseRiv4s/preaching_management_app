import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../captains/presentation/provider/captains_provider.dart';
import '../../domain/model/report_data.dart';
import '../../domain/service/report_service.dart';
import '../provider/report_filters_provider.dart';
import '../widgets/coverage_donut_chart.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/territory_ranking_list.dart';
import '../widgets/report_pdf_exporter.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final reportAsync = ref.watch(reportDataProvider((
      month: filters.month,
      captainId: filters.captainId,
    )));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Informe de Actividad', style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        children: [
          // ── Filtros ──────────────────────────────────
          _FilterBar(),
          // ── Contenido ────────────────────────────────
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (report) => _ReportContent(report: report),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barra de filtros ──────────────────────────────────────
class _FilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);
    final notifier = ref.read(reportFiltersProvider.notifier);
    final captains = ref.watch(captainsProvider).valueOrNull ?? [];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ── Filtro de mes ──────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () => _pickMonth(context, filters, notifier),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.background,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy', 'es').format(filters.month),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Filtro de capitán ──────────────────────
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: filters.captainId,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                prefixIcon: const Icon(Icons.person_rounded,
                    size: 16, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              hint: Text('Todos', style: AppTextStyles.bodyMedium),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todos'),
                ),
                ...captains.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
              ],
              onChanged: (id) {
                final captain = captains.where((c) => c.id == id).firstOrNull;
                notifier.setCaptain(id, captain?.name);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(
    BuildContext context,
    ReportFilters filters,
    ReportFiltersNotifier notifier,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filters.month,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      notifier.setMonth(DateTime(picked.year, picked.month));
    }
  }
}

// ── Contenido del reporte ─────────────────────────────────
class _ReportContent extends ConsumerWidget {
  final ReportData report;
  const _ReportContent({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(reportFiltersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado del mes ───────────────────────
          _SectionHeader(
            title: 'Resumen Mensual',
            subtitle: DateFormat('MMMM yyyy', 'es').format(report.month),
          ),
          const SizedBox(height: 12),

          // ── Cards de resumen ─────────────────────────
          Row(
            children: [
              // Donut de cobertura
              Expanded(
                child: _SummaryCard(
                  child: CoverageDonutChart(
                    coverage: report.territoryCoverage,
                    label: 'Cobertura de\nTerritorio',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Total personas
              Expanded(
                child: _SummaryCard(
                  child: _ParticipantsCard(
                    total: report.totalParticipants,
                    journeys: report.totalJourneys,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Gráfico de barras semanal ────────────────
          _SectionHeader(title: 'Salidas por Semana'),
          const SizedBox(height: 12),
          _SummaryCard(
            child: WeeklyBarChart(weeklyActivity: report.weeklyActivity),
          ),

          const SizedBox(height: 16),

          // ── Ranking de territorios ───────────────────
          _SectionHeader(
            title: 'Ranking de Territorios',
            subtitle: 'por cobertura de predicación',
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            child: TerritoryRankingList(rankings: report.territoryRanking),
          ),

          const SizedBox(height: 24),

          // ── Botón exportar PDF ───────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ReportPdfExporter.export(
                context: context,
                report: report,
                filters: filters,
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Exportar Informe PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.headingSmall),
        if (subtitle != null) Text(subtitle!, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Widget child;
  const _SummaryCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _ParticipantsCard extends StatelessWidget {
  final int total;
  final int journeys;

  const _ParticipantsCard({
    required this.total,
    required this.journeys,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$total',
          style: AppTextStyles.displayLarge.copyWith(
            color: AppColors.primary,
            fontSize: 40,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_rounded,
                size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Total Personas\nSalieron',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$journeys jornadas',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
