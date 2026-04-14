import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/mock/home_mock_data.dart';
import '../../domain/model/preaching_day_summary.dart';
import '../../domain/model/territory_summary.dart';
import '../widgets/block_grid_widget.dart';
import '../widgets/journey_carousel_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../preaching_days/presentation/provider/preaching_days_provider.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final List<TerritorySummary> _territories = HomeMockData.territories;
  int _selectedIndex = 0;

  TerritorySummary get _current => _territories[_selectedIndex];

  void _prev() {
    if (_selectedIndex > 0) setState(() => _selectedIndex--);
  }

  void _next() {
    if (_selectedIndex < _territories.length - 1) {
      setState(() => _selectedIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final journeysAsync = ref.watch(journeysByDateProvider);
    final todayJourneys = journeysAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text('Congregación Villas del Progreso',
                  style: AppTextStyles.headingMedium),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  tooltip: 'Historial',
                  onPressed: () => context.pushNamed('historial'),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Divider(height: 1, color: AppColors.divider),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ── Selector de territorio ──
                  _TerritorySelector(
                    name: _current.name,
                    current: _selectedIndex + 1,
                    total: _territories.length,
                    onPrev: _selectedIndex > 0 ? _prev : null,
                    onNext:
                        _selectedIndex < _territories.length - 1 ? _next : null,
                  ),

                  const SizedBox(height: 8),

                  // ── Stats rápidos ──
                  _TerritoryStats(territory: _current),

                  const SizedBox(height: 8),

                  // ── Grid de bloques ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: BlockGridWidget(blocks: _current.blocks),
                  ),

                  const SizedBox(height: 16),

                  // ── Carrusel de jornadas ──
                  JourneyCarouselWidget(
                    journeys: todayJourneys
                        .map(
                          (j) => PreachingDaySummary(
                            id: j.id,
                            date: j.date,
                            captainName: j.captainName,
                            publisherCount: j.participantCount,
                            territoryName: '',
                            coveredBlocks: j.coveredBlockNumbers,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selector de territorio ──────────────────────────────
class _TerritorySelector extends StatelessWidget {
  final String name;
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _TerritorySelector({
    required this.name,
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Prev
          _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
          const SizedBox(width: 8),
          // Nombre
          Expanded(
            child: Column(
              children: [
                Text(
                  name,
                  style: AppTextStyles.headingSmall,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$current de $total territorios',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Next
          _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color:
              enabled ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.divider,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textDisabled,
          size: 20,
        ),
      ),
    );
  }
}

// ── Stats del territorio ────────────────────────────────
class _TerritoryStats extends StatelessWidget {
  final TerritorySummary territory;

  const _TerritoryStats({required this.territory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatChip(
            label: 'Total',
            value: '${territory.totalBlocks}',
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Completados',
            value: '${territory.completedBlocks}',
            color: AppColors.statusCompleted,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'En progreso',
            value: '${territory.inProgressBlocks}',
            color: AppColors.statusInProgress,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Pendientes',
            value: '${territory.pendingBlocks}',
            color: AppColors.statusPending,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
