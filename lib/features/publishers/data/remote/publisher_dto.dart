class PublisherDto {
  final String id;
  final String name;
  final String? phone;
  final String createdAt;

  const PublisherDto({
    required this.id,
    required this.name,
    this.phone,
    required this.createdAt,
  });

  factory PublisherDto.fromJson(Map<String, dynamic> json) {
    return PublisherDto(
      id:        json['id'] as String,
      name:      json['name'] as String,
      phone:     json['phone'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}