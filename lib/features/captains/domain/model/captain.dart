class Captain {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final DateTime createdAt;

  const Captain({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.createdAt,
  });

  Captain copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    DateTime? createdAt,
  }) {
    return Captain(
      id:        id        ?? this.id,
      name:      name      ?? this.name,
      phone:     phone     ?? this.phone,
      email:     email     ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Captain && other.id == id;

  @override
  int get hashCode => id.hashCode;
}