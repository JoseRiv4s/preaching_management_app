import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../data/local/publisher_local_datasource.dart';
import '../../data/remote/publisher_remote_datasource.dart';
import '../../data/repository/publisher_repository_impl.dart';
import '../../domain/model/publisher.dart';
import '../../domain/repository/publisher_repository.dart';

// ── Dependencias ─────────────────────────────────────────

final _dioProvider = Provider((ref) =>
    DioClient.create(baseUrl: ApiConstants.baseUrl));

final _publisherRemoteProvider = Provider((ref) =>
    PublisherRemoteDatasource(ref.watch(_dioProvider)));

final _publisherLocalProvider = Provider((ref) =>
    PublisherLocalDatasource(ref.watch(appDatabaseProvider)));

final publisherRepositoryProvider = Provider<PublisherRepository>((ref) =>
    PublisherRepositoryImpl(
      ref.watch(_publisherRemoteProvider),
      ref.watch(_publisherLocalProvider),
    ));

// ── Estado: lista de publishers ──────────────────────────

class PublishersNotifier extends AsyncNotifier<List<Publisher>> {
  @override
  Future<List<Publisher>> build() async {
    // Escucha cambios en la DB local en tiempo real
    final stream = ref
        .watch(publisherRepositoryProvider)
        .watchAll();

    ref.listenSelf((_, __) {});

    return stream.first;
  }

  Future<void> create(String name, String? phone) async {
    state = const AsyncLoading();
    try {
      await ref.read(publisherRepositoryProvider).create(name, phone);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updatePublisher(Publisher publisher) async {
    state = const AsyncLoading();
    try {
      await ref.read(publisherRepositoryProvider).update(publisher);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(publisherRepositoryProvider).delete(id);
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> sync() async {
    state = const AsyncLoading();
    try {
      await ref.read(publisherRepositoryProvider).sync();
      await _refresh();
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _refresh() async {
    final list = await ref
        .read(publisherRepositoryProvider)
        .getAll();
    state = AsyncData(list);
  }
}

final publishersProvider =
    AsyncNotifierProvider<PublishersNotifier, List<Publisher>>(
  PublishersNotifier.new,
);