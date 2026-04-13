import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/model/block.dart' as domain;
import '../model/block_mapper.dart';

class BlockLocalDatasource {
  final db.AppDatabase _db;
  BlockLocalDatasource(this._db);

  Stream<List<domain.Block>> watchAll() =>
      _db.blocksDao.watchAll().map(
            (rows) => rows.map(BlockMapper.fromRow).cast<domain.Block>().toList(),
      );

  Stream<List<domain.Block>> watchByTerritory(String territoryId) =>
      _db.blocksDao.watchByTerritory(territoryId).map(
            (rows) => rows.map(BlockMapper.fromRow).cast<domain.Block>().toList(),
      );

  Future<List<domain.Block>> getByTerritory(String territoryId) async {
    final rows = await _db.blocksDao.getByTerritory(territoryId);
    return rows.map(BlockMapper.fromRow).cast<domain.Block>().toList();
  }

  Future<void> upsert(domain.Block block) =>
      _db.blocksDao.upsert(
        db.BlocksCompanion(
          id:          Value(block.id),
          blockNumber: Value(block.blockNumber),
          status:      Value(block.status.value),
          notes:       Value(block.notes),
          territoryId: Value(block.territoryId),
          createdAt:   Value(block.createdAt),
        ),
      );

  Future<void> upsertAll(List<domain.Block> blocks) =>
      _db.blocksDao.replaceAll(
        blocks.map((b) => db.BlocksCompanion(
          id:          Value(b.id),
          blockNumber: Value(b.blockNumber),
          status:      Value(b.status.value),
          notes:       Value(b.notes),
          territoryId: Value(b.territoryId),
          createdAt:   Value(b.createdAt),
        )).toList(),
      );

  Future<void> deleteById(String id) =>
      _db.blocksDao.deleteById(id);
}