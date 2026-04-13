import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/publisher.dart';
import '../provider/publishers_provider.dart';

class PublisherFormSheet extends ConsumerStatefulWidget {
  final Publisher? publisher; // null = crear, not null = editar

  const PublisherFormSheet({super.key, this.publisher});

  @override
  ConsumerState<PublisherFormSheet> createState() =>
      _PublisherFormSheetState();
}

class _PublisherFormSheetState
    extends ConsumerState<PublisherFormSheet> {
  final _formKey  = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _loading = false;

  bool get _isEditing => widget.publisher != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(
        text: widget.publisher?.name ?? '');
    _phoneCtrl = TextEditingController(
        text: widget.publisher?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim().isEmpty
        ? null
        : _phoneCtrl.text.trim();

    if (_isEditing) {
      await ref.read(publishersProvider.notifier).updatePublisher(
            widget.publisher!.copyWith(name: name, phone: phone),
          );
    } else {
      await ref.read(publishersProvider.notifier).create(name, phone);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            Text(
              _isEditing ? 'Editar Publisher' : 'Nuevo Publisher',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 20),

            // Campo nombre
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (v.trim().length < 2) {
                  return 'Mínimo 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo teléfono
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // Botón
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditing ? 'Guardar cambios' : 'Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}