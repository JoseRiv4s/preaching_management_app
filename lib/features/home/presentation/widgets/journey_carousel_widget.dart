import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/preaching_day_summary.dart';

class JourneyCarouselWidget extends StatefulWidget {
  final List<PreachingDaySummary> journeys;

  const JourneyCarouselWidget({super.key, required this.journeys});

  @override
  State<JourneyCarouselWidget> createState() => _JourneyCarouselWidgetState();
}

class _JourneyCarouselWidgetState extends State<JourneyCarouselWidget> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.journeys.isEmpty) return _EmptyJourneys();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Resumen del Día', style: AppTextStyles.headingSmall),
              // Indicador de página
              if (widget.journeys.length > 1)
                Text(
                  '${_currentPage + 1} / ${widget.journeys.length}',
                  style: AppTextStyles.caption,
                ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.journeys.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _JourneyCard(journey: widget.journeys[index]),
              );
            },
          ),
        ),
        // Dots
        if (widget.journeys.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.journeys.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentPage ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final PreachingDaySummary journey;

  const _JourneyCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM yyyy', 'es').format(journey.date);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Fecha',
              value: dateStr,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.person_rounded,
              label: 'Capitán',
              value: journey.captainName,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.group_rounded,
              label: 'Grupo',
              value: '${journey.publisherCount} personas',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.grid_view_rounded,
              label: 'Bloques',
              value: journey.coveredBlocks.join(', '),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Text('$label: ', style: AppTextStyles.bodyMedium),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyJourneys extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.textDisabled, size: 20),
          const SizedBox(width: 12),
          Text(
            'No hay jornadas registradas hoy',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}