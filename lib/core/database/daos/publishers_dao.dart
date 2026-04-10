import 'package:drift/drift.dart';
import '../app_database.dart';

part 'publishers_dao.g.dart';

@DriftAccessor(tables: [Publishers])
class PublishersDao extends DatabaseAccessor<AppDatabase>
    with _$PublishersDaoMixin {
  PublishersDao(super.db);

  Future<List<Publisher>> getAll() => select(publishers).get();
  Stream<List<Publisher>> watchAll() => select(publishers).watch();

  Future<Publisher?> getById(String id) =>
      (select(publishers)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsert(PublishersCompanion entry) =>
      into(publishers).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (delete(publishers)..where((t) => t.id.equals(id))).go();

  Future<void> replaceAll(List<PublishersCompanion> entries) async {
    await transaction(() async {
      await delete(publishers).go();
      await batch((b) => b.insertAll(publishers, entries));
    });
  }
}