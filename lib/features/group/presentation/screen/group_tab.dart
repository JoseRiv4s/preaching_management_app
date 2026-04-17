import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../publishers/presentation/widgets/publisher_form_sheet.dart';
import '../../../publishers/presentation/screen/publishers_screen.dart';
import '../../../captains/presentation/screen/captains_screen.dart';
import '../../../captains/presentation/widgets/captain_form_sheet.dart';
import '../../../publishers/presentation/provider/publishers_provider.dart';
import '../../../captains/presentation/provider/captains_provider.dart';

// Enum
enum _GroupSection { captains, publishers }

String _search = '';

class GroupTab extends ConsumerStatefulWidget {
  const GroupTab({super.key});

  @override
  ConsumerState<GroupTab> createState() => _GroupTabState();
}

class _GroupTabState extends ConsumerState<GroupTab> {
  _GroupSection _section = _GroupSection.captains;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gestión de Usuarios', style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Botón +
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _onRegister(context),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registrar Nuevo Usuario',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SegmentedSelector(
                selected: _section,
                onChanged: (s) => setState(() => _section = s),
              ),
            ),

            const SizedBox(height: 12),

            // 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: _section == _GroupSection.publishers
                    ? PublishersScreen(search: _search)
                    : CaptainsScreen(search: _search),
              ),
            ),

            // Footer
            Consumer(
              builder: (context, ref, _) {
                final captains = ref.watch(captainsProvider).valueOrNull ?? [];
                final publishers =
                    ref.watch(publishersProvider).valueOrNull ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 70),
                  padding: const EdgeInsets.all(10),
                  color: AppColors.surface,
                  child: Text(
                    'Total: ${captains.length} Capitanes / '
                    '${publishers.length} Publicadores',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onRegister(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _section == _GroupSection.publishers
          ? const PublisherFormSheet()
          : const CaptainFormSheet(),
    );
  }
}

/// ===============================
/// SEGMENTED
/// ===============================

class _SegmentedSelector extends StatelessWidget {
  final _GroupSection selected;
  final ValueChanged<_GroupSection> onChanged;

  const _SegmentedSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _SegmentItem(
            label: 'Capitanes',
            isActive: selected == _GroupSection.captains,
            onTap: () => onChanged(_GroupSection.captains),
          ),
          _SegmentItem(
            label: 'Publicadores',
            isActive: selected == _GroupSection.publishers,
            onTap: () => onChanged(_GroupSection.publishers),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
