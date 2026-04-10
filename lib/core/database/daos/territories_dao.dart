import 'package:drift/drift.dart';
import '../app_database.dart';

part 'territories_dao.g.dart';

@DriftAccessor(tables: [Territories])
class TerritoriesDao extends DatabaseAccessor<AppDatabase>
    with _$TerritoriesDaoMixin {
  TerritoriesDao(super.db);

  Future<List<Territory>> getAll() => select(territories).get();
  Stream<List<Territory>> watchAll() => select(territories).watch();

  Future<Territory?> getById(String id) =>
      (select(territories)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsert(TerritoriesCompanion entry) =>
      into(territories).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (delete(territories)..where((t) => t.id.equals(id))).go();

  Future<void> replaceAll(List<TerritoriesCompanion> entries) async {
    await transaction(() async {
      await delete(territories).go();
      await batch((b) => b.insertAll(territories, entries));
    });
  }
}