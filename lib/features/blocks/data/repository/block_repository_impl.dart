import 'package:uuid/uuid.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/model/block.dart';
import '../../domain/repository/block_repository.dart';
import '../local/block_local_datasource.dart';
import '../remote/block_remote_datasource.dart';
import '../model/block_mapper.dart';

class BlockRepositoryImpl implements BlockRepository {
  final BlockRemoteDatasource _remote;
  final BlockLocalDatasource  _local;

  BlockRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<Block>> watchAll() => _local.watchAll();

  @override
  Stream<List<Block>> watchByTerritory(String territoryId) =>
      _local.watchByTerritory(territoryId);

  @override
  Future<List<Block>> getByTerritory(String territoryId) =>
      _local.getByTerritory(territoryId);

  @override
  Future<void> create({
    required String blockNumber,
    required String territoryId,
    String? notes,
  }) async {
    try {
      final dto = await _remote.create(
        blockNumber: blockNumber,
        territoryId: territoryId,
        notes: notes,
      );
      await _local.upsert(BlockMapper.fromDto(dto));
    } on AppException {
      await _local.upsert(Block(
        id:          const Uuid().v4(),
        blockNumber: blockNumber,
        status:      BlockStatus.pending,
        notes:       notes,
        territoryId: territoryId,
        createdAt:   DateTime.now(),
      ));
    }
  }

  @override
  Future<void> update(Block block) async {
    try {
      final dto = await _remote.update(
        block.id,
        block.blockNumber,
        block.status.value,
        block.notes,
      );
      await _local.upsert(BlockMapper.fromDto(dto));
    } on AppException {
      await _local.upsert(block);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.deleteById(id);
    try {
      await _remote.delete(id);
    } on AppException {}
  }

  @override
  Future<void> sync() async {
    try {
      final dtos = await _remote.getAll();
      await _local.upsertAll(dtos.map(BlockMapper.fromDto).toList());
    } on AppException {}
  }
}