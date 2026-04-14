import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../blocks/domain/model/block.dart';
import '../../../blocks/presentation/provider/blocks_provider.dart';
import '../../../territories/domain/model/territory.dart';
import '../../../territories/presentation/provider/territories_provider.dart';
import '../provider/nueva_salida_form_provider.dart';

class Step3Bloques extends ConsumerStatefulWidget {
  const Step3Bloques({super.key});

  @override
  ConsumerState<Step3Bloques> createState() => _Step3BloquesState();
}

class _Step3BloquesState extends ConsumerState<Step3Bloques> {
  Territory? _selectedTerritory;

  @override
  Widget build(BuildContext context) {
    final form       = ref.watch(nuevaSalidaFormProvider);
    final notifier   = ref.read(nuevaSalidaFormProvider.notifier);
    final territories = ref.watch(territoriesProvider).valueOrNull ?? [];

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Bloques cubiertos',
                  style: AppTextStyles.headingSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: form.selectedBlocks.isNotEmpty
                      ? AppColors.success
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${form.selectedBlocks.length} seleccionados',
                  style: AppTextStyles.caption.copyWith(
                    color: form.selectedBlocks.isNotEmpty
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selector de territorio
        Padding(
          padding: const EdgeInsets.all(16),
          child: _TerritoryDropdown(
            territories:        territories,
            selectedTerritory:  _selectedTerritory,
            onChanged: (t) =>
                setState(() => _selectedTerritory = t),
          ),
        ),

        // Grid de bloques
        Expanded(
          child: _selectedTerritory == null
              ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined,
                    size: 48,
                    color: AppColors.textDisabled),
                const SizedBox(height: 12),
                Text(
                  'Selecciona un territorio\npara ver sus bloques',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : _BlocksGrid(
            territoryId:    _selectedTerritory!.id,
            selectedBlocks: form.selectedBlocks,
            onToggle:       notifier.toggleBlock,
          ),
        ),
      ],
    );
  }
}

class _TerritoryDropdown extends StatelessWidget {
  final List<Territory> territories;
  final Territory? selectedTerritory;
  final ValueChanged<Territory?> onChanged;

  const _TerritoryDropdown({
    required this.territories,
    required this.selectedTerritory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Territory>(
      value: selectedTerritory,
      hint: const Text('Seleccionar territorio'),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.map_outlined),
        labelText: 'Territorio',
      ),
      items: territories.map((t) {
        return DropdownMenuItem(
          value: t,
          child: Text(t.name),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _BlocksGrid extends ConsumerWidget {
  final String territoryId;
  final List<Block> selectedBlocks;
  final ValueChanged<Block> onToggle;

  const _BlocksGrid({
    required this.territoryId,
    required this.selectedBlocks,
    required this.onToggle,
  });

  Color _color(BlockStatus s) => switch (s) {
    BlockStatus.completed  => AppColors.statusCompleted,
    BlockStatus.inProgress => AppColors.statusInProgress,
    BlockStatus.pending    => AppColors.statusPending,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync =
    ref.watch(blocksByTerritoryProvider(territoryId));

    return blocksAsync.when(
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text(e.toString())),
      data: (blocks) {
        if (blocks.isEmpty) {
          return Center(
            child: Text(
              'Este territorio no tiene bloques',
              style: AppTextStyles.bodyMedium,
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: blocks.length,
          itemBuilder: (_, i) {
            final block = blocks[i];
            final isSelected = selectedBlocks.contains(block);
            final color = _color(block.status);

            return GestureDetector(
              onTap: () => onToggle(block),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : color,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        block.blockNumber,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? Colors.white
                              : color,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 9,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}