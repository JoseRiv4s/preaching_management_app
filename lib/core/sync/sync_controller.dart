import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';

// Este controller escucha la conectividad y sincroniza
// automáticamente cuando vuelve la conexión
class SyncController {
  final Ref _ref;

  SyncController(this._ref) {
    _init();
  }

  void _init() {
    _ref.listen<AsyncValue<bool>>(
      isOnlineProvider,
          (previous, next) {
        final wasOffline = previous?.valueOrNull == false;
        final isNowOnline = next.valueOrNull == true;

        // Solo sincroniza cuando RECUPERA conexión
        if (wasOffline && isNowOnline) {
          _sync();
        }
      },
    );
  }

  Future<void> _sync() async {
    final syncService = _ref.read(syncServiceProvider);
    await syncService.fullSync(_ref);
  }
}

final syncControllerProvider = Provider<SyncController>((ref) {
  return SyncController(ref);
});