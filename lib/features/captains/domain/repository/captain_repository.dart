import '../model/captain.dart';

abstract class CaptainRepository {
  Stream<List<Captain>> watchAll();
  Future<List<Captain>> getAll();
  Future<Captain?> getById(String id);
  Future<void> create(String name, String? phone, String? email);
  Future<void> update(Captain captain);
  Future<void> delete(String id);
  Future<void> sync();
}