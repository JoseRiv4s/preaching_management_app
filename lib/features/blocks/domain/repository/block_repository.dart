import '../model/block.dart';

abstract class BlockRepository {
  Stream<List<Block>> watchAll();
  Stream<List<Block>> watchByTerritory(String territoryId);
  Future<List<Block>> getByTerritory(String territoryId);
  Future<void> create({
    required String blockNumber,
    required String territoryId,
    String? notes,
  });
  Future<void> update(Block block);
  Future<void> delete(String id);
  Future<void> sync();
}