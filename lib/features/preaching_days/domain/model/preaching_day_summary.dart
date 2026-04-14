class PreachingDaySummaryModel {
  final String id;
  final DateTime date;
  final String captainId;
  final String captainName;
  final int participantCount;
  final List<String> coveredBlockNumbers;
  final String? notes;
  final DateTime createdAt;

  const PreachingDaySummaryModel({
    required this.id,
    required this.date,
    required this.captainId,
    required this.captainName,
    required this.participantCount,
    required this.coveredBlockNumbers,
    this.notes,
    required this.createdAt,
  });
}