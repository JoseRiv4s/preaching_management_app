import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/block.dart';
import '../provider/blocks_provider.dart';

class BlockFormSheet extends ConsumerStatefulWidget {
  final Block? block;
  final String territoryId;

  const BlockFormSheet({
    super.key,
    this.block,
    required this.territoryId,
  });

  @override
  ConsumerState<BlockFormSheet> createState() =>
      _BlockFormSheetState();
}

class _BlockFormSheetState extends ConsumerState<BlockFormSheet> {
  final _formKey    = GlobalKey<FormState>();
  late final TextEditingController _numberCtrl;
  late final TextEditingController _notesCtrl;
  late BlockStatus _status;
  bool _loading = false;

  bool get _isEditing => widget.block != null;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController(
        text: widget.block?.blockNumber ?? '');
    _notesCtrl  = TextEditingController(
        text: widget.block?.notes ?? '');
    _status     = widget.block?.status ?? BlockStatus.pending;
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final number = _numberCtrl.text.trim();
    final notes  = _notesCtrl.text.trim().isEmpty
        ? null : _notesCtrl.text.trim();

    if (_isEditing) {
      await ref.read(blocksProvider.notifier).updateBlock(
        widget.block!.copyWith(
          blockNumber: number,
          status: _status,
          notes: notes,
        ),
      );
    } else {
      await ref.read(blocksProvider.notifier).create(
        blockNumber: number,
        territoryId: widget.territoryId,
        notes: notes,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEditing ? 'Editar Bloque' : 'Nuevo Bloque',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 20),

            // Número de bloque
            TextFormField(
              controller: _numberCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Número de bloque *',
                prefixIcon: Icon(Icons.grid_view_rounded),
                hintText: 'Ej: A1, B2, Norte-3',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El número es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status (solo visible en edición)
            if (_isEditing) ...[
              Text('Estado', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              _StatusSelector(
                selected: _status,
                onChanged: (s) => setState(() => _status = s),
              ),
              const SizedBox(height: 16),
            ],

            // Notas
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(_isEditing
                    ? 'Guardar cambios'
                    : 'Crear bloque'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final BlockStatus selected;
  final ValueChanged<BlockStatus> onChanged;

  const _StatusSelector({
    required this.selected,
    required this.onChanged,
  });

  Color _color(BlockStatus s) => switch (s) {
    BlockStatus.completed  => AppColors.statusCompleted,
    BlockStatus.inProgress => AppColors.statusInProgress,
    BlockStatus.pending    => AppColors.statusPending,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BlockStatus.values.map((s) {
        final isSelected = selected == s;
        final color = _color(s);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : AppColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? color
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}