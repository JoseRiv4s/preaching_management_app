import 'package:drift/drift.dart';
import '../app_database.dart';

part 'blocks_dao.g.dart';

@DriftAccessor(tables: [Blocks])
class BlocksDao extends DatabaseAccessor<AppDatabase>
    with _$BlocksDaoMixin {
  BlocksDao(super.db);

  Future<List<Block>> getAll() => select(blocks).get();
  Stream<List<Block>> watchAll() => select(blocks).watch();

  // Bloques por territorio
  Stream<List<Block>> watchByTerritory(String territoryId) =>
      (select(blocks)
            ..where((t) => t.territoryId.equals(territoryId)))
          .watch();

  Future<List<Block>> getByTerritory(String territoryId) =>
      (select(blocks)
            ..where((t) => t.territoryId.equals(territoryId)))
          .get();

  Future<void> upsert(BlocksCompanion entry) =>
      into(blocks).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (delete(blocks)..where((t) => t.id.equals(id))).go();

  Future<void> replaceAll(List<BlocksCompanion> entries) async {
    await transaction(() async {
      await delete(blocks).go();
      await batch((b) => b.insertAll(blocks, entries));
    });
  }
}