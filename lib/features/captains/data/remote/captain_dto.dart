class CaptainDto {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String createdAt;

  const CaptainDto({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.createdAt,
  });

  factory CaptainDto.fromJson(Map<String, dynamic> json) {
    return CaptainDto(
      id:        json['id'] as String,
      name:      json['name'] as String,
      phone:     json['phone'] as String?,
      email:     json['email'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }
}