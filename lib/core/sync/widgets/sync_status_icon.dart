import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../connectivity_service.dart';
import '../sync_service.dart';

class SyncStatusIcon extends ConsumerWidget {
  const SyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).valueOrNull ?? true;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            isOnline
                ? Icons.cloud_done_rounded
                : Icons.cloud_off_rounded,
            color: isOnline
                ? AppColors.success
                : AppColors.warning,
          ),
          onPressed: isOnline
              ? () => _manualSync(context, ref)
              : null,
          tooltip: isOnline ? 'Sincronizar' : 'Sin conexión',
        ),
      ],
    );
  }

  Future<void> _manualSync(
      BuildContext context, WidgetRef ref) async {
    final result =
    await ref.read(syncServiceProvider).processQueue();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success > 0
              ? AppColors.success
              : AppColors.info,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}