class TerritorySummary {
  final String id;
  final String name;
  final List<BlockSummary> blocks;

  const TerritorySummary({
    required this.id,
    required this.name,
    required this.blocks,
  });

  int get totalBlocks => blocks.length;
  int get completedBlocks =>
      blocks.where((b) => b.status == BlockStatus.completed).length;
  int get inProgressBlocks =>
      blocks.where((b) => b.status == BlockStatus.inProgress).length;
  int get pendingBlocks =>
      blocks.where((b) => b.status == BlockStatus.pending).length;
}

class BlockSummary {
  final String id;
  final String blockNumber;
  final BlockStatus status;

  const BlockSummary({
    required this.id,
    required this.blockNumber,
    required this.status,
  });
}

enum BlockStatus { pending, inProgress, completed }