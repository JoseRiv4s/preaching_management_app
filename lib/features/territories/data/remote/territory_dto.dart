class TerritoryDto {
  final String id;
  final String name;
  final String createdAt;

  const TerritoryDto({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory TerritoryDto.fromJson(Map<String, dynamic> json) =>
      TerritoryDto(
        id:        json['id'] as String,
        name:      json['name'] as String,
        createdAt: json['createdAt'] as String,
      );
}