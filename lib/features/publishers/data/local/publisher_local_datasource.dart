import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' as db;
import '../model/publisher_mapper.dart';
import '../../domain/model/publisher.dart' as domain;

class PublisherLocalDatasource {
  final db.AppDatabase _db;
  PublisherLocalDatasource(this._db);

  Stream<List<domain.Publisher>> watchAll() =>
      _db.publishersDao.watchAll().map(
        (rows) => rows.map(PublisherMapper.fromRow).cast<domain.Publisher>().toList(),
      );

  Future<List<domain.Publisher>> getAll() async {
    final rows = await _db.publishersDao.getAll();
    return rows.map(PublisherMapper.fromRow).cast<domain.Publisher>().toList();
  }

  Future<domain.Publisher?> getById(String id) async {
    final row = await _db.publishersDao.getById(id);
    return row != null ? PublisherMapper.fromRow(row) : null as domain.Publisher?;
  }

  Future<void> upsert(domain.Publisher publisher) =>
      _db.publishersDao.upsert(
        db.PublishersCompanion(
          id:        Value(publisher.id),
          name:      Value(publisher.name),
          phone:     Value(publisher.phone),
          createdAt: Value(publisher.createdAt),
        ),
      );

  Future<void> upsertAll(List<domain.Publisher> publishers) =>
      _db.publishersDao.replaceAll(
        publishers.map((p) => db.PublishersCompanion(
          id:        Value(p.id),
          name:      Value(p.name),
          phone:     Value(p.phone),
          createdAt: Value(p.createdAt),
        )).toList(),
      );

  Future<void> deleteById(String id) =>
      _db.publishersDao.deleteById(id);
}