import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/local/captain_local_datasource.dart';
import '../../data/remote/captain_remote_datasource.dart';
import '../../data/repository/captain_repository_impl.dart';
import '../../domain/model/captain.dart';
import '../../domain/repository/captain_repository.dart';

final _dioProvider = Provider((ref) =>
    DioClient.create(baseUrl: ApiConstants.baseUrl));

final _captainRemoteProvider = Provider((ref) =>
    CaptainRemoteDatasource(ref.watch(_dioProvider)));

final _captainLocalProvider = Provider((ref) =>
    CaptainLocalDatasource(ref.watch(appDatabaseProvider)));

final captainRepositoryProvider = Provider<CaptainRepository>((ref) =>
    CaptainRepositoryImpl(
      ref.watch(_captainRemoteProvider),
      ref.watch(_captainLocalProvider),
    ));

// ── State ────────────────────────────────────────────────

class CaptainsNotifier extends AsyncNotifier<List<Captain>> {
  @override
  Future<List<Captain>> build() async {
    return ref.watch(captainRepositoryProvider).watchAll().first;
  }

  Future<void> create(
      String name, String? phone, String? email) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(captainRepositoryProvider)
          .create(name, phone, email);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateCaptain(Captain captain) async {
    state = const AsyncLoading();
    try {
      await ref.read(captainRepositoryProvider).update(captain);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(captainRepositoryProvider).delete(id);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> sync() async {
    state = const AsyncLoading();
    try {
      await ref.read(captainRepositoryProvider).sync();
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _refresh() async {
    final list =
    await ref.read(captainRepositoryProvider).getAll();
    state = AsyncData(list);
  }
}

final captainsProvider =
AsyncNotifierProvider<CaptainsNotifier, List<Captain>>(
  CaptainsNotifier.new,
);