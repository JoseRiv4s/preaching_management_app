enum SyncEntity {
  publisher,
  captain,
  territory,
  block,
  preachingDay,
}

enum SyncOperation { create, update, delete }

class SyncItem {
  final String id;
  final SyncEntity entity;
  final SyncOperation operation;
  final Map<String, dynamic> payload;
  final int attempts;
  final DateTime createdAt;

  const SyncItem({
    required this.id,
    required this.entity,
    required this.operation,
    required this.payload,
    required this.attempts,
    required this.createdAt,
  });
}