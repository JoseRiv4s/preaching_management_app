class PreachingDayDto {
  final String id;
  final String date;
  final String captainId;
  final String? notes;
  final String createdAt;
  final List<String> participantIds;
  final List<String> blockIds;

  const PreachingDayDto({
    required this.id,
    required this.date,
    required this.captainId,
    this.notes,
    required this.createdAt,
    required this.participantIds,
    required this.blockIds,
  });

  factory PreachingDayDto.fromJson(Map<String, dynamic> json) {
    return PreachingDayDto(
      id:             json['id'] as String,
      date:           json['date'] as String,
      captainId:      json['captainId'] as String,
      notes:          json['notes'] as String?,
      createdAt:      json['createdAt'] as String,
      participantIds: (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      blockIds: (json['blockIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
    );
  }
}