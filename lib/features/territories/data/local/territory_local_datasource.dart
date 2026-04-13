import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/model/territory.dart' as domain;
import '../model/territory_mapper.dart';

class TerritoryLocalDatasource {
  final db.AppDatabase _db;
  TerritoryLocalDatasource(this._db);

  Stream<List<domain.Territory>> watchAll() =>
      _db.territoriesDao.watchAll().map(
            (rows) => rows.map(TerritoryMapper.fromRow).cast<domain.Territory>().toList(),
      );

  Future<List<domain.Territory>> getAll() async {
    final rows = await _db.territoriesDao.getAll();
    return rows.map(TerritoryMapper.fromRow).cast<domain.Territory>().toList();
  }

  Future<void> upsert(domain.Territory territory) =>
      _db.territoriesDao.upsert(
        db.TerritoriesCompanion(
          id:        Value(territory.id),
          name:      Value(territory.name),
          createdAt: Value(territory.createdAt),
        ),
      );

  Future<void> upsertAll(List<domain.Territory> territories) =>
      _db.territoriesDao.replaceAll(
        territories.map((t) => db.TerritoriesCompanion(
          id:        Value(t.id),
          name:      Value(t.name),
          createdAt: Value(t.createdAt),
        )).toList(),
      );

  Future<void> deleteById(String id) =>
      _db.territoriesDao.deleteById(id);
}