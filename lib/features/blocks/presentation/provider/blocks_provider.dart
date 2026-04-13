import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/local/block_local_datasource.dart';
import '../../data/remote/block_remote_datasource.dart';
import '../../data/repository/block_repository_impl.dart';
import '../../domain/model/block.dart';
import '../../domain/repository/block_repository.dart';

final _dioProvider = Provider((ref) =>
    DioClient.create(baseUrl: ApiConstants.baseUrl));

final _blockRemoteProvider = Provider((ref) =>
    BlockRemoteDatasource(ref.watch(_dioProvider)));

final _blockLocalProvider = Provider((ref) =>
    BlockLocalDatasource(ref.watch(appDatabaseProvider)));

final blockRepositoryProvider =
Provider<BlockRepository>((ref) => BlockRepositoryImpl(
  ref.watch(_blockRemoteProvider),
  ref.watch(_blockLocalProvider),
));

// Provider de bloques por territorio
final blocksByTerritoryProvider = StreamProvider.family<List<Block>, String>(
      (ref, territoryId) => ref
      .watch(blockRepositoryProvider)
      .watchByTerritory(territoryId),
);

class BlocksNotifier extends AsyncNotifier<List<Block>> {
  @override
  Future<List<Block>> build() async => [];

  Future<void> create({
    required String blockNumber,
    required String territoryId,
    String? notes,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(blockRepositoryProvider).create(
        blockNumber: blockNumber,
        territoryId: territoryId,
        notes: notes,
      );
      await _refresh(territoryId);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> updateBlock(Block block) async {
    state = const AsyncLoading();
    try {
      await ref.read(blockRepositoryProvider).update(block);
      await _refresh(block.territoryId);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> delete(Block block) async {
    state = const AsyncLoading();
    try {
      await ref.read(blockRepositoryProvider).delete(block.id);
      await _refresh(block.territoryId);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> sync() async {
    state = const AsyncLoading();
    try {
      await ref.read(blockRepositoryProvider).sync();
      state = const AsyncData([]);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _refresh(String territoryId) async {
    state = AsyncData(await ref
        .read(blockRepositoryProvider)
        .getByTerritory(territoryId));
  }
}

final blocksProvider =
AsyncNotifierProvider<BlocksNotifier, List<Block>>(
  BlocksNotifier.new,
);