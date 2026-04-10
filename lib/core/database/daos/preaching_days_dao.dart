import 'package:drift/drift.dart';
import '../app_database.dart';

part 'preaching_days_dao.g.dart';

@DriftAccessor(tables: [PreachingDays, PreachingParticipants, PreachedBlocks])
class PreachingDaysDao extends DatabaseAccessor<AppDatabase>
    with _$PreachingDaysDaoMixin {
  PreachingDaysDao(super.db);

  Future<List<PreachingDay>> getAll() => select(preachingDays).get();
  Stream<List<PreachingDay>> watchAll() => select(preachingDays).watch();

  // Jornadas por fecha (para el carrusel del home)
  Stream<List<PreachingDay>> watchByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end   = start.add(const Duration(days: 1));
    return (select(preachingDays)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .watch();
  }

  Future<void> upsert(PreachingDaysCompanion entry) =>
      into(preachingDays).insertOnConflictUpdate(entry);

  Future<void> deleteById(String id) =>
      (delete(preachingDays)..where((t) => t.id.equals(id))).go();

  // Participantes de una jornada
  Future<List<PreachingParticipant>> getParticipants(
          String preachingDayId) =>
      (select(preachingParticipants)
            ..where((t) => t.preachingDayId.equals(preachingDayId)))
          .get();

  // Bloques de una jornada
  Future<List<PreachedBlock>> getPreachedBlocks(
          String preachingDayId) =>
      (select(preachedBlocks)
            ..where((t) => t.preachingDayId.equals(preachingDayId)))
          .get();
}