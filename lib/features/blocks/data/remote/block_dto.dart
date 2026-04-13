class BlockDto {
  final String id;
  final String blockNumber;
  final String status;
  final String? notes;
  final String territoryId;
  final String createdAt;

  const BlockDto({
    required this.id,
    required this.blockNumber,
    required this.status,
    this.notes,
    required this.territoryId,
    required this.createdAt,
  });

  factory BlockDto.fromJson(Map<String, dynamic> json) => BlockDto(
    id:          json['id'] as String,
    blockNumber: json['blockNumber'] as String,
    status:      json['status'] as String,
    notes:       json['notes'] as String?,
    territoryId: json['territoryId'] as String,
    createdAt:   json['createdAt'] as String,
  );
}