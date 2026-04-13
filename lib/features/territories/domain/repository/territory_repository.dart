import '../model/territory.dart';

abstract class TerritoryRepository {
  Stream<List<Territory>> watchAll();
  Future<List<Territory>> getAll();
  Future<Territory?> getById(String id);
  Future<void> create(String name);
  Future<void> update(Territory territory);
  Future<void> delete(String id);
  Future<void> sync();
}