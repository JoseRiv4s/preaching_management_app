import '../model/preaching_day.dart';
import '../model/preaching_day_summary.dart';

abstract class PreachingDayRepository {
  // Stream reactivo de jornadas por fecha
  Stream<List<PreachingDaySummaryModel>> watchByDate(DateTime date);

  // Historial paginado
  Future<List<PreachingDaySummaryModel>> getHistory({
    int page = 0,
    int pageSize = 20,
  });

  // Detalle completo de una jornada
  Future<PreachingDay?> getById(String id);

  // Crear jornada completa
  Future<void> create({
    required DateTime date,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  });

  // Actualizar
  Future<void> update({
    required String id,
    required String captainId,
    required List<String> publisherIds,
    required List<String> blockIds,
    String? notes,
  });

  Future<void> delete(String id);

  Future<void> sync();
}