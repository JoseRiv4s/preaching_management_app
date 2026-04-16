import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged => _connectivity
      .onConnectivityChanged
      .map((results) => _isConnected(results));

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) =>
    r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }
}

// Provider global de conectividad
final connectivityServiceProvider = Provider<ConnectivityService>(
      (ref) => ConnectivityService(),
);

// Stream provider — true = online, false = offline
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

// Provider del estado actual (sin stream)
final connectivityStatusProvider = FutureProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).isConnected;
});