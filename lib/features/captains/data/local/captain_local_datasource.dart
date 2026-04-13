import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../domain/model/captain.dart' as domain;
import '../model/captain_mapper.dart';

class CaptainLocalDatasource {
  final db.AppDatabase _db;
  CaptainLocalDatasource(this._db);

  Stream<List<domain.Captain>> watchAll() =>
      _db.captainsDao.watchAll().map(
            (rows) => rows.map(CaptainMapper.fromRow).cast<domain.Captain>().toList(),
      );

  Future<List<domain.Captain>> getAll() async {
    final rows = await _db.captainsDao.getAll();
    return rows.map(CaptainMapper.fromRow).cast<domain.Captain>().toList();
  }

  Future<domain.Captain?> getById(String id) async {
    final row = await _db.captainsDao.getById(id);
    return row != null ? CaptainMapper.fromRow(row) : null;
  }

  Future<void> upsert(domain.Captain captain) =>
      _db.captainsDao.upsert(
        db.CaptainsCompanion(
          id:        Value(captain.id),
          name:      Value(captain.name),
          phone:     Value(captain.phone),
          email:     Value(captain.email),
          createdAt: Value(captain.createdAt),
        ),
      );

  Future<void> upsertAll(List<domain.Captain> captains) =>
      _db.captainsDao.replaceAll(
        captains.map((c) => db.CaptainsCompanion(
          id:        Value(c.id),
          name:      Value(c.name),
          phone:     Value(c.phone),
          email:     Value(c.email),
          createdAt: Value(c.createdAt),
        )).toList(),
      );

  Future<void> deleteById(String id) =>
      _db.captainsDao.deleteById(id);
}