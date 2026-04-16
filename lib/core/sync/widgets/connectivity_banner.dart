import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../connectivity_service.dart';
import '../sync_service.dart';

class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return isOnline.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (online) {
        if (online) return _OnlineBanner(ref: ref);
        return _OfflineBanner();
      },
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 16),
      color: AppColors.warning,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Sin conexión — modo offline activo',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineBanner extends StatefulWidget {
  final WidgetRef ref;
  const _OnlineBanner({required this.ref});

  @override
  State<_OnlineBanner> createState() => _OnlineBannerState();
}

class _OnlineBannerState extends State<_OnlineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  bool _show = false;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(
        parent: _controller, curve: Curves.easeInOut);
    _checkPending();
  }

  Future<void> _checkPending() async {
    final count = await widget.ref
        .read(syncServiceProvider)
        .getPendingCount();

    if (count > 0 && mounted) {
      setState(() {
        _pendingCount = count;
        _show = true;
      });
      _controller.forward();

      // Auto-ocultar después de 4 segundos
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        await _controller.reverse();
        setState(() => _show = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            vertical: 8, horizontal: 16),
        color: AppColors.success,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sync_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Conexión restaurada · '
                  'Sincronizando $_pendingCount cambios...',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}