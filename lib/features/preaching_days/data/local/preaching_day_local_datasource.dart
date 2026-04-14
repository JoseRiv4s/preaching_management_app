import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/model/preaching_day_summary.dart';

class PreachingDayLocalDatasource {
  final AppDatabase _db;
  PreachingDayLocalDatasource(this._db);

  // Stream de jornadas por fecha con datos enriquecidos
  Stream<List<PreachingDaySummaryModel>> watchByDate(
      DateTime date) {
    return _db.preachingDaysDao.watchByDate(date).asyncMap(
          (days) async => Future.wait(days.map((d) async {
        // Capitán
        final captain = await _db.captainsDao.getById(d.captainId);

        // Participantes
        final participants =
        await _db.preachingDaysDao.getParticipants(d.id);

        // Bloques cubiertos
        final preachedBlocks =
        await _db.preachingDaysDao.getPreachedBlocks(d.id);

        // Números de bloque
        final blockNumbers = await Future.wait(
          preachedBlocks.map((pb) async {
            final blocks = await _db.blocksDao.getAll();
            final block = blocks
                .where((b) => b.id == pb.blockId)
                .firstOrNull;
            return block?.blockNumber ?? pb.blockId;
          }),
        );

        return PreachingDaySummaryModel(
          id:                   d.id,
          date:                 d.date,
          captainId:            d.captainId,
          captainName:          captain?.name ?? 'Desconocido',
          participantCount:     participants.length,
          coveredBlockNumbers:  blockNumbers,
          notes:                d.notes,
          createdAt:            d.createdAt,
        );
      })),
    );
  }

  Future<List<PreachingDaySummaryModel>> getHistory({
    int page = 0,
    int pageSize = 20,
  }) async {
    final days = await _db.preachingDaysDao.getAll();

    // Ordenar por fecha descendente y paginar
    days.sort((a, b) => b.date.compareTo(a.date));
    final paged = days.skip(page * pageSize).take(pageSize).toList();

    return Future.wait(paged.map((d) async {
      final captain =
      await _db.captainsDao.getById(d.captainId);
      final participants =
      await _db.preachingDaysDao.getParticipants(d.id);
      final preachedBlocks =
      await _db.preachingDaysDao.getPreachedBlocks(d.id);
      final allBlocks = await _db.blocksDao.getAll();

      final blockNumbers = preachedBlocks.map((pb) {
        final block =
            allBlocks.where((b) => b.id == pb.blockId).firstOrNull;
        return block?.blockNumber ?? pb.blockId;
      }).toList();

      return PreachingDaySummaryModel(
        id:                  d.id,
        date:                d.date,
        captainId:           d.captainId,
        captainName:         captain?.name ?? 'Desconocido',
        participantCount:    participants.length,
        coveredBlockNumbers: blockNumbers,
        notes:               d.notes,
        createdAt:           d.createdAt,
      );
    }));
  }

  Future<void> savePreachingDay({
    required String id,
    required DateTime date,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  }) async {
    await _db.transaction(() async {
      // 1. Guardar jornada
      await _db.preachingDaysDao.upsert(
        PreachingDaysCompanion(
          id:        Value(id),
          date:      Value(date),
          captainId: Value(captainId),
          notes:     Value(notes),
          createdAt: Value(DateTime.now()),
        ),
      );

      // 2. Eliminar participantes y bloques anteriores
      final oldParticipants =
      await _db.preachingDaysDao.getParticipants(id);
      for (final p in oldParticipants) {
        await (_db.delete(_db.preachingParticipants)
          ..where((t) => t.id.equals(p.id)))
            .go();
      }

      final oldBlocks =
      await _db.preachingDaysDao.getPreachedBlocks(id);
      for (final b in oldBlocks) {
        await (_db.delete(_db.preachedBlocks)
          ..where((t) => t.id.equals(b.id)))
            .go();
      }

      // 3. Insertar nuevos participantes
      for (final publisherId in publisherIds) {
        await _db.into(_db.preachingParticipants).insert(
          PreachingParticipantsCompanion(
            id:             Value('${id}_$publisherId'),
            preachingDayId: Value(id),
            publisherId:    Value(publisherId),
          ),
        );
      }

      // 4. Insertar nuevos bloques
      for (final blockId in blockIds) {
        await _db.into(_db.preachedBlocks).insert(
          PreachedBlocksCompanion(
            id:             Value('${id}_$blockId'),
            preachingDayId: Value(id),
            blockId:        Value(blockId),
          ),
        );
      }
    });
  }

  Future<void> deleteById(String id) async {
    await _db.preachingDaysDao.deleteById(id);
  }
}