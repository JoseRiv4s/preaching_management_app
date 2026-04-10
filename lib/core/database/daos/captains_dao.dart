import 'package:drift/drift.dart';
import '../app_database.dart';

part 'captains_dao.g.dart';

@DriftAccessor(tables: [Captains])
class CaptainsDao extends DatabaseAccessor<AppDatabase>
    with _$CaptainsDaoMixin {
  CaptainsDao(super.db);

  // Todos los capitanes
  Future<List<Captain>> getAll() => select(captains).get();

  // Stream reactivo (se actualiza automáticamente)
  Stream<List<Captain>> watchAll() => select(captains).watch();

  // Buscar por ID
  Future<Captain?> getById(String id) =>
      (select(captains)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  // Insertar o reemplazar
  Future<void> upsert(CaptainsCompanion entry) =>
      into(captains).insertOnConflictUpdate(entry);

  // Eliminar
  Future<void> deleteById(String id) =>
      (delete(captains)..where((t) => t.id.equals(id))).go();

  // Reemplazar toda la tabla (para sync completo)
  Future<void> replaceAll(List<CaptainsCompanion> entries) async {
    await transaction(() async {
      await delete(captains).go();
      await batch((b) => b.insertAll(captains, entries));
    });
  }
}