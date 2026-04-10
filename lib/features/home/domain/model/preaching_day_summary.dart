class PreachingDaySummary {
  final String id;
  final DateTime date;
  final String captainName;
  final int publisherCount;
  final String territoryName;
  final List<String> coveredBlocks;

  const PreachingDaySummary({
    required this.id,
    required this.date,
    required this.captainName,
    required this.publisherCount,
    required this.territoryName,
    required this.coveredBlocks,
  });
}