import 'package:uuid/uuid.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/model/territory.dart';
import '../../domain/repository/territory_repository.dart';
import '../local/territory_local_datasource.dart';
import '../remote/territory_remote_datasource.dart';
import '../model/territory_mapper.dart';

class TerritoryRepositoryImpl implements TerritoryRepository {
  final TerritoryRemoteDatasource _remote;
  final TerritoryLocalDatasource  _local;

  TerritoryRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<Territory>> watchAll() => _local.watchAll();

  @override
  Future<List<Territory>> getAll() => _local.getAll();

  @override
  Future<Territory?> getById(String id) async {
    final all = await _local.getAll();
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> create(String name) async {
    try {
      final dto = await _remote.create(name);
      await _local.upsert(TerritoryMapper.fromDto(dto));
    } on AppException {
      await _local.upsert(Territory(
        id:        const Uuid().v4(),
        name:      name,
        createdAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> update(Territory territory) async {
    try {
      final dto = await _remote.update(territory.id, territory.name);
      await _local.upsert(TerritoryMapper.fromDto(dto));
    } on AppException {
      await _local.upsert(territory);
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
      await _local.upsertAll(
          dtos.map(TerritoryMapper.fromDto).toList());
    } on AppException {}
  }
}