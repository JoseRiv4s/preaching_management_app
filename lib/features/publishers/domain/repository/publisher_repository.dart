import '../model/publisher.dart';

// Contrato: define QUÉ se puede hacer, no CÓMO
abstract class PublisherRepository {
  /// Retorna la lista local inmediatamente,
  /// luego sincroniza con el backend en background
  Stream<List<Publisher>> watchAll();

  Future<List<Publisher>> getAll();

  Future<Publisher?> getById(String id);

  Future<void> create(String name, String? phone);

  Future<void> update(Publisher publisher);

  Future<void> delete(String id);

  /// Fuerza sincronización con el backend
  Future<void> sync();
}