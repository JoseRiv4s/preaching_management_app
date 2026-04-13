class Territory {
  final String id;
  final String name;
  final DateTime createdAt;

  const Territory({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  Territory copyWith({String? id, String? name, DateTime? createdAt}) {
    return Territory(
      id:        id        ?? this.id,
      name:      name      ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Territory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}