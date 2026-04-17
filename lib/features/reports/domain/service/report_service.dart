import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../model/report_data.dart';

class ReportService {
  final AppDatabase _db;
  ReportService(this._db);

  Future<ReportData> generateMonthlyReport({
    required DateTime month,
    String? captainId,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    // ── Jornadas del mes ──────────────────────────────
    final allDays = await _db.preachingDaysDao.getAll();
    var monthDays = allDays
        .where((d) =>
            d.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            d.date.isBefore(end))
        .toList();

    // Filtrar por capitán si aplica
    if (captainId != null && captainId.isNotEmpty) {
      monthDays = monthDays.where((d) => d.captainId == captainId).toList();
    }

    // ── Total participantes únicos ─────────────────────
    final participantSet = <String>{};
    for (final day in monthDays) {
      final participants = await _db.preachingDaysDao.getParticipants(day.id);
      for (final p in participants) {
        participantSet.add(p.publisherId);
      }
    }

    // ── Actividad semanal ──────────────────────────────
    final weeklyMap = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};
    for (final day in monthDays) {
      final week = ((day.date.day - 1) ~/ 7) + 1;
      final clampedWeek = week.clamp(1, 4);
      weeklyMap[clampedWeek] = (weeklyMap[clampedWeek] ?? 0) + 1;
    }

    final weeklyActivity = weeklyMap.entries
        .map((e) => WeekActivity(week: e.key, journeyCount: e.value))
        .toList()
      ..sort((a, b) => a.week.compareTo(b.week));

    // ── Ranking de territorios ─────────────────────────
    final territories = await _db.territoriesDao.getAll();
    final allBlocks = await _db.blocksDao.getAll();

    final rankings = <TerritoryRanking>[];

    for (final territory in territories) {
      final tBlocks =
          allBlocks.where((b) => b.territoryId == territory.id).toList();
      final total = tBlocks.length;
      final completed = tBlocks.where((b) => b.status == 'COMPLETED').length;
      final coverage = total > 0 ? completed / total : 0.0;

      rankings.add(TerritoryRanking(
        territoryId: territory.id,
        territoryName: territory.name,
        coverage: coverage,
        completedBlocks: completed,
        totalBlocks: total,
        rank: 0,
      ));
    }

    // Ordenar por cobertura descendente
    rankings.sort((a, b) => b.coverage.compareTo(a.coverage));

    final rankedList = rankings
        .asMap()
        .entries
        .map((e) => TerritoryRanking(
              territoryId: e.value.territoryId,
              territoryName: e.value.territoryName,
              coverage: e.value.coverage,
              completedBlocks: e.value.completedBlocks,
              totalBlocks: e.value.totalBlocks,
              rank: e.key + 1,
            ))
        .toList();

    // ── Cobertura global ───────────────────────────────
    final totalBlocks = allBlocks.length;
    final completedBlocks =
        allBlocks.where((b) => b.status == 'COMPLETED').length;
    final globalCoverage =
        totalBlocks > 0 ? completedBlocks / totalBlocks : 0.0;

    return ReportData(
      month: month,
      captainFilter: captainId,
      territoryCoverage: globalCoverage,
      totalParticipants: participantSet.length,
      totalJourneys: monthDays.length,
      weeklyActivity: weeklyActivity,
      territoryRanking: rankedList,
    );
  }
}

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.watch(appDatabaseProvider));
});

final reportDataProvider =
    FutureProvider.family<ReportData, ({DateTime month, String? captainId})>(
        (ref, params) {
  return ref.watch(reportServiceProvider).generateMonthlyReport(
        month: params.month,
        captainId: params.captainId,
      );
});
