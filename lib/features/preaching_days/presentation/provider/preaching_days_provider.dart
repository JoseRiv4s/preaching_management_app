import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/local/preaching_day_local_datasource.dart';
import '../../data/remote/preaching_day_remote_datasource.dart';
import '../../data/repository/preaching_day_repository_impl.dart';
import '../../domain/model/preaching_day_summary.dart';
import '../../domain/repository/preaching_day_repository.dart';

final _dioProvider = Provider((ref) =>
    DioClient.create(baseUrl: ApiConstants.baseUrl));

final _pdRemoteProvider = Provider((ref) =>
    PreachingDayRemoteDatasource(ref.watch(_dioProvider)));

final _pdLocalProvider = Provider((ref) =>
    PreachingDayLocalDatasource(ref.watch(appDatabaseProvider)));

final preachingDayRepositoryProvider =
Provider<PreachingDayRepository>((ref) =>
    PreachingDayRepositoryImpl(
      ref.watch(_pdRemoteProvider),
      ref.watch(_pdLocalProvider),
    ));

// Stream de jornadas del día seleccionado
final selectedDateProvider =
StateProvider<DateTime>((ref) => DateTime.now());

final journeysByDateProvider =
StreamProvider<List<PreachingDaySummaryModel>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref
      .watch(preachingDayRepositoryProvider)
      .watchByDate(date);
});

// Historial completo
final journeyHistoryProvider =
FutureProvider<List<PreachingDaySummaryModel>>((ref) {
  return ref
      .watch(preachingDayRepositoryProvider)
      .getHistory();
});

// Notifier para crear/actualizar/eliminar
class PreachingDaysNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> create({
    required DateTime date,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(preachingDayRepositoryProvider).create(
        date:         date,
        captainId:    captainId,
        publisherIds: publisherIds,
        blockIds:     blockIds,
        notes:        notes,
      );
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(preachingDayRepositoryProvider).delete(id);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final preachingDaysNotifierProvider =
AsyncNotifierProvider<PreachingDaysNotifier, void>(
  PreachingDaysNotifier.new,
);