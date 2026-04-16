import 'package:drift/drift.dart';
import '../app_database.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueData>> getPending() =>
      select(syncQueue).get();

  Stream<List<SyncQueueData>> watchPending() =>
      select(syncQueue).watch();

  Future<int> getPendingCount() async {
    final items = await select(syncQueue).get();
    return items.length;
  }

  Future<void> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<void> deleteById(String id) =>
      (delete(syncQueue)..where((t) => t.id.equals(id))).go();

  Future<void> incrementAttempts(String id) async {
    final item = await (select(syncQueue)
      ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (item != null) {
      await (update(syncQueue)..where((t) => t.id.equals(id)))
          .write(SyncQueueCompanion(
        attempts: Value(item.attempts + 1),
      ));
    }
  }

  Future<void> clearAll() => delete(syncQueue).go();
}