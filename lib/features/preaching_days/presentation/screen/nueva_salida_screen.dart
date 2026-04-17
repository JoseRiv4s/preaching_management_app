import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../provider/nueva_salida_form_provider.dart';
import '../provider/preaching_days_provider.dart';
import '../widgets/step1_fecha_capitan.dart';
import '../widgets/step2_publishers.dart';
import '../widgets/step3_bloques.dart';
import 'package:go_router/go_router.dart';

class NuevaSalidaScreen extends ConsumerStatefulWidget {
  const NuevaSalidaScreen({super.key});

  @override
  ConsumerState<NuevaSalidaScreen> createState() => _NuevaSalidaScreenState();
}

class _NuevaSalidaScreenState extends ConsumerState<NuevaSalidaScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Fecha y Capitán',
    'Participantes',
    'Bloques cubiertos',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    final form = ref.read(nuevaSalidaFormProvider);

    final success =
        await ref.read(preachingDaysNotifierProvider.notifier).create(
              date: form.date,
              captainId: form.captain!.id,
              publisherIds: form.selectedPublishers.map((p) => p.id).toList(),
              blockIds: form.selectedBlocks.map((b) => b.id).toList(),
              notes: form.notes,
            );

    if (success && mounted) {
      ref.read(nuevaSalidaFormProvider.notifier).reset();
      context.goNamed('home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Jornada registrada exitosamente!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _canAdvance() {
    final form = ref.watch(nuevaSalidaFormProvider);
    return switch (_currentStep) {
      0 => form.isStep1Valid,
      1 => form.isStep2Valid,
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(nuevaSalidaFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Nueva Salida', style: AppTextStyles.headingMedium),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(nuevaSalidaFormProvider.notifier).reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // ── Stepper indicator ──────────────────────────
          _StepIndicator(
            currentStep: _currentStep,
            titles: _stepTitles,
          ),

          // ── Páginas del formulario ─────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                Step1FechaCapitan(),
                Step2Publishers(),
                Step3Bloques(),
              ],
            ),
          ),

          // ── Resumen rápido ─────────────────────────────
          if (_currentStep > 0) _QuickSummary(form: form),

          // ── Botones de navegación ──────────────────────
          _NavigationButtons(
            currentStep: _currentStep,
            canAdvance: _canAdvance(),
            onBack: _prevStep,
            onNext: _nextStep,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> titles;

  const _StepIndicator({
    required this.currentStep,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(titles.length, (i) {
          final isActive = i == currentStep;
          final isComplete = i < currentStep;

          return Expanded(
            child: Row(
              children: [
                // Círculo
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? AppColors.success
                        : isActive
                            ? AppColors.primary
                            : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isComplete
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textDisabled,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                // Título
                Expanded(
                  child: Text(
                    titles[i],
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : isComplete
                              ? AppColors.success
                              : AppColors.textDisabled,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Línea conectora
                if (i < titles.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 16,
                      height: 2,
                      color: i < currentStep
                          ? AppColors.success
                          : AppColors.divider,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Resumen rápido ────────────────────────────────────────
class _QuickSummary extends StatelessWidget {
  final NuevaSalidaFormState form;
  const _QuickSummary({required this.form});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          if (form.captain != null) ...[
            Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(form.captain!.name,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.primary)),
            const SizedBox(width: 12),
          ],
          if (form.selectedPublishers.isNotEmpty) ...[
            Icon(Icons.group_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('${form.selectedPublishers.length} publishers',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.primary)),
            const SizedBox(width: 12),
          ],
          if (form.selectedBlocks.isNotEmpty) ...[
            Icon(Icons.grid_view_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text('${form.selectedBlocks.length} bloques',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.primary)),
          ],
        ],
      ),
    );
  }
}

// ── Botones de navegación ─────────────────────────────────
class _NavigationButtons extends ConsumerWidget {
  final int currentStep;
  final bool canAdvance;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _NavigationButtons({
    required this.currentStep,
    required this.canAdvance,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(preachingDaysNotifierProvider).isLoading;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Atrás'),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : canAdvance
                      ? currentStep == 2
                          ? onSubmit
                          : onNext
                      : null,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(currentStep == 2 ? 'Registrar Jornada' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}
