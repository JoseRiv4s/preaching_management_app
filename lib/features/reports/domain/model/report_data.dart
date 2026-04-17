class ReportData {
  final DateTime month;
  final String? captainFilter;

  // Resumen mensual
  final double territoryCoverage; // 0.0 - 1.0
  final int totalParticipants;
  final int totalJourneys;

  // Salidas por semana
  final List<WeekActivity> weeklyActivity;

  // Ranking de territorios
  final List<TerritoryRanking> territoryRanking;

  const ReportData({
    required this.month,
    this.captainFilter,
    required this.territoryCoverage,
    required this.totalParticipants,
    required this.totalJourneys,
    required this.weeklyActivity,
    required this.territoryRanking,
  });
}

class WeekActivity {
  final int week; // 1, 2, 3, 4
  final int journeyCount;

  const WeekActivity({
    required this.week,
    required this.journeyCount,
  });
}

class TerritoryRanking {
  final String territoryId;
  final String territoryName;
  final double coverage; // 0.0 - 1.0
  final int completedBlocks;
  final int totalBlocks;
  final int rank;

  const TerritoryRanking({
    required this.territoryId,
    required this.territoryName,
    required this.coverage,
    required this.completedBlocks,
    required this.totalBlocks,
    required this.rank,
  });
}
