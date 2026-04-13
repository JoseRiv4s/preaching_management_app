import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/local/territory_local_datasource.dart';
import '../../data/remote/territory_remote_datasource.dart';
import '../../data/repository/territory_repository_impl.dart';
import '../../domain/model/territory.dart';
import '../../domain/repository/territory_repository.dart';

final _dioProvider = Provider((ref) =>
    DioClient.create(baseUrl: ApiConstants.baseUrl));

final _territoryRemoteProvider = Provider((ref) =>
    TerritoryRemoteDatasource(ref.watch(_dioProvider)));

final _territoryLocalProvider = Provider((ref) =>
    TerritoryLocalDatasource(ref.watch(appDatabaseProvider)));

final territoryRepositoryProvider =
Provider<TerritoryRepository>((ref) => TerritoryRepositoryImpl(
  ref.watch(_territoryRemoteProvider),
  ref.watch(_territoryLocalProvider),
));

class TerritoriesNotifier extends AsyncNotifier<List<Territory>> {
  @override
  Future<List<Territory>> build() async =>
      ref.watch(territoryRepositoryProvider).watchAll().first;

  Future<void> create(String name) async {
    state = const AsyncLoading();
    try {
      await ref.read(territoryRepositoryProvider).create(name);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateTerritory(Territory territory) async {
    state = const AsyncLoading();
    try {
      await ref.read(territoryRepositoryProvider).update(territory);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(territoryRepositoryProvider).delete(id);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> sync() async {
    state = const AsyncLoading();
    try {
      await ref.read(territoryRepositoryProvider).sync();
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _refresh() async {
    state = AsyncData(
        await ref.read(territoryRepositoryProvider).getAll());
  }
}

final territoriesProvider =
AsyncNotifierProvider<TerritoriesNotifier, List<Territory>>(
  TerritoriesNotifier.new,
);