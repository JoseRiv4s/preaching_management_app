import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/model/captain.dart';
import '../provider/captains_provider.dart';

class CaptainFormSheet extends ConsumerStatefulWidget {
  final Captain? captain;
  const CaptainFormSheet({super.key, this.captain});

  @override
  ConsumerState<CaptainFormSheet> createState() =>
      _CaptainFormSheetState();
}

class _CaptainFormSheetState extends ConsumerState<CaptainFormSheet> {
  final _formKey   = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  bool _loading = false;

  bool get _isEditing => widget.captain != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(
        text: widget.captain?.name ?? '');
    _phoneCtrl = TextEditingController(
        text: widget.captain?.phone ?? '');
    _emailCtrl = TextEditingController(
        text: widget.captain?.email ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim().isEmpty
        ? null : _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim().isEmpty
        ? null : _emailCtrl.text.trim();

    if (_isEditing) {
      await ref.read(captainsProvider.notifier).updateCaptain(
        widget.captain!.copyWith(
          name: name, phone: phone, email: email,
        ),
      );
    } else {
      await ref
          .read(captainsProvider.notifier)
          .create(name, phone, email);
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

            Text(
              _isEditing ? 'Editar Capitán' : 'Nuevo Capitán',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 20),

            // Nombre
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

            // Teléfono
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (opcional)',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  final valid = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(v.trim());
                  if (!valid) return 'Email inválido';
                }
                return null;
              },
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
                    : Text(_isEditing
                    ? 'Guardar cambios'
                    : 'Crear capitán'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}