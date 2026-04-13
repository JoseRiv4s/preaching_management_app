import 'package:uuid/uuid.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/model/captain.dart';
import '../../domain/repository/captain_repository.dart';
import '../local/captain_local_datasource.dart';
import '../remote/captain_remote_datasource.dart';
import '../model/captain_mapper.dart';

class CaptainRepositoryImpl implements CaptainRepository {
  final CaptainRemoteDatasource _remote;
  final CaptainLocalDatasource  _local;

  CaptainRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<Captain>> watchAll() => _local.watchAll();

  @override
  Future<List<Captain>> getAll() => _local.getAll();

  @override
  Future<Captain?> getById(String id) => _local.getById(id);

  @override
  Future<void> create(String name, String? phone, String? email) async {
    try {
      final dto = await _remote.create(name, phone, email);
      await _local.upsert(CaptainMapper.fromDto(dto));
    } on AppException {
      final captain = Captain(
        id:        const Uuid().v4(),
        name:      name,
        phone:     phone,
        email:     email,
        createdAt: DateTime.now(),
      );
      await _local.upsert(captain);
    }
  }

  @override
  Future<void> update(Captain captain) async {
    try {
      final dto = await _remote.update(
        captain.id, captain.name, captain.phone, captain.email,
      );
      await _local.upsert(CaptainMapper.fromDto(dto));
    } on AppException {
      await _local.upsert(captain);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.deleteById(id);
    try {
      await _remote.delete(id);
    } on AppException {
      // TODO: encolar para sync posterior
    }
  }

  @override
  Future<void> sync() async {
    try {
      final dtos    = await _remote.getAll();
      final captains = dtos.map(CaptainMapper.fromDto).toList();
      await _local.upsertAll(captains);
    } on AppException {
      // Sin conexión, usamos caché local
    }
  }
}