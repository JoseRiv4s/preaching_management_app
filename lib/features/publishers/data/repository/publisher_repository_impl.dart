import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/model/publisher.dart';
import '../../domain/repository/publisher_repository.dart';
import '../local/publisher_local_datasource.dart';
import '../remote/publisher_remote_datasource.dart';
import '../model/publisher_mapper.dart';
import 'package:uuid/uuid.dart';

class PublisherRepositoryImpl implements PublisherRepository {
  final PublisherRemoteDatasource _remote;
  final PublisherLocalDatasource  _local;

  PublisherRepositoryImpl(this._remote, this._local);

  @override
  Stream<List<Publisher>> watchAll() => _local.watchAll();

  @override
  Future<List<Publisher>> getAll() => _local.getAll();

  @override
  Future<Publisher?> getById(String id) => _local.getById(id);

  @override
  Future<void> create(String name, String? phone) async {
    try {
      // 1. Intenta crear en el backend
      final dto = await _remote.create(name, phone);
      // 2. Guarda en local con el ID del backend
      await _local.upsert(PublisherMapper.fromDto(dto));
    } on AppException {
      // 3. Sin conexión: guarda local con UUID temporal
      final publisher = Publisher(
        id:        const Uuid().v4(),
        name:      name,
        phone:     phone,
        createdAt: DateTime.now(),
      );
      await _local.upsert(publisher);
    }
  }

  @override
  Future<void> update(Publisher publisher) async {
    try {
      final dto = await _remote.update(
        publisher.id, publisher.name, publisher.phone,
      );
      await _local.upsert(PublisherMapper.fromDto(dto));
    } on AppException {
      // Sin conexión: actualiza solo local
      await _local.upsert(publisher);
    }
  }

  @override
  Future<void> delete(String id) async {
    // Elimina local primero (UX inmediata)
    await _local.deleteById(id);
    try {
      await _remote.delete(id);
    } on AppException {
      // Si falla el backend, ya está eliminado local
      // TODO: encolar para sync posterior
    }
  }

  @override
  Future<void> sync() async {
    try {
      final dtos = await _remote.getAll();
      final publishers = dtos.map(PublisherMapper.fromDto).toList();
      await _local.upsertAll(publishers);
    } on AppException {
      // Sin conexión, usamos caché local
    }
  }
}