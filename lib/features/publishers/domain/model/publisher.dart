class Publisher {
  final String id;
  final String name;
  final String? phone;
  final DateTime createdAt;

  const Publisher({
    required this.id,
    required this.name,
    this.phone,
    required this.createdAt,
  });

  // Para editar: copia con campos modificados
  Publisher copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) {
    return Publisher(
      id:        id        ?? this.id,
      name:      name      ?? this.name,
      phone:     phone     ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Publisher && other.id == id;

  @override
  int get hashCode => id.hashCode;
}