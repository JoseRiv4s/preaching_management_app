enum BlockStatus { pending, inProgress, completed }

extension BlockStatusX on BlockStatus {
  String get label => switch (this) {
    BlockStatus.pending    => 'Pendiente',
    BlockStatus.inProgress => 'En progreso',
    BlockStatus.completed  => 'Completado',
  };

  // Convierte a/desde el string que usa la DB y el backend
  String get value => switch (this) {
    BlockStatus.pending    => 'PENDING',
    BlockStatus.inProgress => 'IN_PROGRESS',
    BlockStatus.completed  => 'COMPLETED',
  };

  static BlockStatus fromValue(String v) => switch (v) {
    'PENDING'     => BlockStatus.pending,
    'IN_PROGRESS' => BlockStatus.inProgress,
    'COMPLETED'   => BlockStatus.completed,
    _             => BlockStatus.pending,
  };
}

class Block {
  final String id;
  final String blockNumber;
  final BlockStatus status;
  final String? notes;
  final String territoryId;
  final DateTime createdAt;

  const Block({
    required this.id,
    required this.blockNumber,
    required this.status,
    this.notes,
    required this.territoryId,
    required this.createdAt,
  });

  Block copyWith({
    String? id,
    String? blockNumber,
    BlockStatus? status,
    String? notes,
    String? territoryId,
    DateTime? createdAt,
  }) {
    return Block(
      id:          id          ?? this.id,
      blockNumber: blockNumber ?? this.blockNumber,
      status:      status      ?? this.status,
      notes:       notes       ?? this.notes,
      territoryId: territoryId ?? this.territoryId,
      createdAt:   createdAt   ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Block && other.id == id;

  @override
  int get hashCode => id.hashCode;
}